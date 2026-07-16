import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:globaledu_ai/app.dart';
import 'package:globaledu_ai/core/config/env_config.dart';
import 'package:globaledu_ai/core/config/firebase_guard.dart';

/// Set this to true after running `flutterfire configure`
/// and importing DefaultFirebaseOptions.
const bool _firebaseConfigured = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
    EnvConfig.initialize();
  } catch (e) {
    debugPrint('⚠️ .env file not found, using defaults');
  }

  // Initialize Firebase only when configured
  if (_firebaseConfigured) {
    // Uncomment after running `flutterfire configure`:
    //
    // import 'package:firebase_core/firebase_core.dart';
    // import 'firebase_options.dart';
    //
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.currentPlatform,
    // );
    FirebaseGuard.markInitialized();
    debugPrint('✅ Firebase initialized');
  } else {
    debugPrint('ℹ️ Firebase not configured. Running in demo mode.');
    debugPrint('   Run "flutterfire configure" to enable Firebase.');
  }

  // Initialize localization
  await EasyLocalization.ensureInitialized();

  // Initialize screen utils
  await ScreenUtil.ensureScreenSize();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('tr'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const ProviderScope(
        child: GlobalEduApp(),
      ),
    ),
  );
}
