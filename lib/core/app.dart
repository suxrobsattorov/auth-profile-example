import 'package:auth_profile_example/presentation/screens/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:auth_profile_example/core/constants/constants.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginPage(),
    );
  }
}
