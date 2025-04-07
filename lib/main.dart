import 'package:flutter/material.dart';
import 'app.dart';

void main() {
  runApp(const CardInfo());
}

// import 'package:flutter/material.dart';
// import 'app.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'firebase_options.dart';
// import 'dart:async';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//
//   // Enable Crashlytics
//   FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
//
//   runZonedGuarded(
//         () => runApp(const CardInfo()),
//         (error, stackTrace) =>
//         FirebaseCrashlytics.instance.recordError(error, stackTrace),
//   );
// }
