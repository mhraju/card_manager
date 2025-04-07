import 'package:card_manager/presentation/screens/login_screen.dart';
import 'package:card_manager/utility/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CardInfo extends StatelessWidget {
  const CardInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
      theme: ThemeData(
        colorSchemeSeed: AppColors.primaryColor,
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: AppColors.primaryColor),
        textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            headlineSmall: TextStyle(
              fontSize: 14,
              color: Colors.blueGrey,
            )),
      ),
    );
  }
}
