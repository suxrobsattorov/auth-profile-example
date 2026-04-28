import 'package:auth_profile_example/presentation/screens/main/main_shell_page.dart';
import 'package:flutter/material.dart';
import 'package:auth_profile_example/core/constants/constants.dart';
import 'package:auth_profile_example/presentation/screens/auth/login_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainShellPage(
          phoneNumber: '+998886180111', countryName: 'O\'zbekiston', flagEmoji: '🇺🇿'),
    );
  }
}
