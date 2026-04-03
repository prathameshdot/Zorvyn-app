import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zorvyn/config/exceptions.dart';
import 'package:zorvyn/models/ai_model.dart';
import 'package:zorvyn/services/api_service.dart';

class AiChatState {
  final List<ChatMessage> messages;
  final bool isSending;
  final String? error;

  const AiChatState({this.messages = const [], this.isSending = false, this.error});

  AiChatState copyWith({List<ChatMessage>? messages, bool? isSending, String? error}) {
    return AiChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  final ApiService _api;
  String? _conversationId;

  AiChatNotifier(this._api) : super(const AiChatState());

  String? get conversationId => _conversationId;

  Future<void> loadConversation(String conversationId) async {
    _conversationId = conversationId;
    try {
      final res = await _api.get('/ai/chat/$conversationId');
      final conv = AiConversation.fromJson(res['conversation'] ?? res);
      state = AiChatState(messages: conv.messages);
    } on AppException catch (e) {
      state = state.copyWith(error: e.message);
    } catch (_) {
      state = state.copyWith(error: 'Failed to load conversation.');
    }
  }

  Future<void> sendMessage(String message, {String? period}) async {
    final userMsg = ChatMessage(role: 'user', content: message);
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isSending: true,
      error: null,
    );

    try {
      final data = <String, dynamic>{'message': message};
      if (_conversationId != null) data['conversationId'] = _conversationId;
      if (period != null) data['period'] = period;

      final res = await _api.post('/ai/chat', data: data);
      _conversationId ??= res['conversationId']?.toString();

      final reply = ChatMessage(
        role: 'assistant',
        content: res['response']?.toString() ?? res['message']?.toString() ?? '',
      );
      state = state.copyWith(
        messages: [...state.messages, reply],
        isSending: false,
      );
    } on AppException catch (e) {
      state = state.copyWith(isSending: false, error: e.message);
    } catch (_) {
      state = state.copyWith(isSending: false, error: 'Failed to get response.');
    }
  }
}

final aiChatNotifierProvider =
    StateNotifierProvider.autoDispose<AiChatNotifier, AiChatState>((ref) {
  return AiChatNotifier(ref.read(apiServiceProvider));
});

final aiConversationsProvider =
    FutureProvider.autoDispose<List<AiConversation>>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    final res = await api.get('/ai/chats');
    return (res['conversations'] ?? res['data'] ?? [])
        .map<AiConversation>((e) => AiConversation.fromJson(e))
        .toList();
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to load conversations.');
  }
});

final aiAnalyzeProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    return await api.post('/ai/analyze-spending');
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to analyze spending.');
  }
});

final aiPredictProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    return await api.post('/ai/predict');
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to get predictions.');
  }
});

final aiOptimizeBudgetProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiServiceProvider);
  try {
    return await api.post('/ai/optimize-budget');
  } catch (e) {
    if (e is AppException) rethrow;
    throw AppException('Failed to optimize budget.');
  }
});

Future<String?> deleteAiConversation(WidgetRef ref, String conversationId) async {
  final api = ref.read(apiServiceProvider);
  try {
    await api.delete('/ai/chat/$conversationId');
    ref.invalidate(aiConversationsProvider);
    return null;
  } on AppException catch (e) {
    return e.message;
  } catch (_) {
    return 'Failed to delete conversation.';
  }
}
