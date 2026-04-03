import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zorvyn/config/router.dart';
import 'package:zorvyn/config/theme.dart';
import 'package:zorvyn/services/connectivity_service.dart';
import 'package:zorvyn/services/database_service.dart';
import 'package:zorvyn/services/local_storage_service.dart';
import 'package:zorvyn/services/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.initialize();
  await DatabaseService.initialize();
  await ConnectivityService.initialize();
  await Firebase.initializeApp();
  await PushNotificationService.initialize();
  runApp(const ProviderScope(child: ZorvynApp()));
}

class ZorvynApp extends ConsumerWidget {
  const ZorvynApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Zorvyn',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      scrollBehavior: const CupertinoScrollBehavior(),
    );
  }
}
