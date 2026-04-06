import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zorvyn/config/constants.dart';
import 'package:zorvyn/config/exceptions.dart';
import 'package:zorvyn/services/connectivity_service.dart';
import 'package:zorvyn/services/database_service.dart';
import 'package:zorvyn/services/local_storage_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBase,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = LocalStorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));

    // Verbose API logging — prints method, URL, headers, payload, and response
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('┌───────────────────────────────────────────');
        debugPrint('│ → ${options.method} ${options.uri}');
        debugPrint('│ Headers: ${options.headers}');
        if (options.data != null) {
          try {
            final encoded = const JsonEncoder.withIndent('  ').convert(options.data);
            debugPrint('│ Body: $encoded');
          } catch (_) {
            debugPrint('│ Body: ${options.data}');
          }
        }
        if (options.queryParameters.isNotEmpty) {
          debugPrint('│ Query: ${options.queryParameters}');
        }
        debugPrint('└───────────────────────────────────────────');
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('┌───────────────────────────────────────────');
        debugPrint('│ ← ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}');
        try {
          final encoded = const JsonEncoder.withIndent('  ').convert(response.data);
          debugPrint('│ Response: $encoded');
        } catch (_) {
          debugPrint('│ Response: ${response.data}');
        }
        debugPrint('└───────────────────────────────────────────');
        handler.next(response);
      },
      onError: (error, handler) {
        debugPrint('┌─── ERROR ─────────────────────────────────');
        debugPrint('│ ✖ ${error.requestOptions.method} ${error.requestOptions.uri}');
        debugPrint('│ Status: ${error.response?.statusCode ?? 'N/A'}');
        if (error.response?.data != null) {
          try {
            final encoded = const JsonEncoder.withIndent('  ').convert(error.response!.data);
            debugPrint('│ Error body: $encoded');
          } catch (_) {
            debugPrint('│ Error body: ${error.response!.data}');
          }
        }
        debugPrint('│ Message: ${error.message}');
        debugPrint('└───────────────────────────────────────────');
        handler.next(error);
      },
    ));
  }

  String _cacheKey(String path, Map<String, dynamic>? queryParams) {
    final buffer = StringBuffer(path);
    if (queryParams != null && queryParams.isNotEmpty) {
      final sorted = queryParams.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
      buffer.write('?');
      buffer.write(sorted.map((e) => '${e.key}=${e.value}').join('&'));
    }
    return buffer.toString();
  }

  // Generic response handler — unwraps the { success, data } envelope
  dynamic _handleResponse(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      if (body['success'] == false) {
        throw AppException(
          body['message']?.toString() ?? 'Something went wrong. Please try again.',
          statusCode: response.statusCode,
        );
      }
      // Unwrap: return inner `data` map if present, otherwise the full body
      final inner = body['data'];
      if (inner is Map<String, dynamic>) return inner;
      return body;
    }
    return body;
  }

  // Generic error handler
  Never _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      throw NetworkException('Connection timed out. Please check your internet and try again.');
    }

    if (e.type == DioExceptionType.connectionError || e.error is SocketException) {
      throw NetworkException();
    }

    final response = e.response;
    if (response != null) {
      final data = response.data;
      final message = data is Map ? (data['message']?.toString() ?? '') : '';

      switch (response.statusCode) {
        case 401:
          throw UnauthorizedException(
            message.isNotEmpty ? message : 'Session expired. Please login again.',
          );
        case 400:
          throw ValidationException(
            message.isNotEmpty ? message : 'Please check your input and try again.',
            statusCode: 400,
          );
        case 404:
          throw AppException(
            message.isNotEmpty ? message : 'The requested item was not found.',
            statusCode: 404,
          );
        case 429:
          throw AppException(
            'Too many requests. Please wait a moment and try again.',
            statusCode: 429,
          );
        default:
          throw ServerException(
            message.isNotEmpty ? message : 'Something went wrong on our end. Please try again.',
          );
      }
    }

    throw NetworkException();
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParams}) async {
    final key = _cacheKey(path, queryParams);
    try {
      final response = await _dio.get(path, queryParameters: queryParams);
      final result = _handleResponse(response) as Map<String, dynamic>;
      // Cache successful GET responses
      DatabaseService.cacheResponse(key, result);
      return result;
    } on DioException catch (e) {
      // On network error, try returning cached data
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.error is SocketException) {
        final cached = await DatabaseService.getCachedResponse(key);
        if (cached != null) return cached;
      }
      _handleError(e);
    }
  }

  Future<Map<String, dynamic>> post(String path, {dynamic data}) async {
    if (!ConnectivityService.isOnline) {
      throw NetworkException('You\'re offline. Please connect to the internet to perform this action.');
    }
    try {
      final response = await _dio.post(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  Future<Map<String, dynamic>> put(String path, {dynamic data}) async {
    if (!ConnectivityService.isOnline) {
      throw NetworkException('You\'re offline. Please connect to the internet to perform this action.');
    }
    try {
      final response = await _dio.put(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  Future<Map<String, dynamic>> delete(String path) async {
    if (!ConnectivityService.isOnline) {
      throw NetworkException('You\'re offline. Please connect to the internet to perform this action.');
    }
    try {
      final response = await _dio.delete(path);
      return _handleResponse(response);
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  /// Replay any pending writes that were queued while offline
  Future<void> syncPendingWrites() async {
    final pending = await DatabaseService.getPendingWrites();
    for (final write in pending) {
      try {
        final method = write['method'] as String;
        final path = write['path'] as String;
        final body = write['body'] != null
            ? Map<String, dynamic>.from(
                (write['body'] as String).isNotEmpty
                    ? Map<String, dynamic>.from({})
                    : {},
              )
            : null;

        switch (method) {
          case 'POST':
            await post(path, data: body);
          case 'PUT':
            await put(path, data: body);
          case 'DELETE':
            await delete(path);
        }
        await DatabaseService.removePendingWrite(write['id'] as int);
      } catch (_) {
        // Will retry next time
        break;
      }
    }
  }
}
