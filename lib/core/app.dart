import 'package:flutter/material.dart';

import 'constants/constants.dart';
import '../infrastructure/network/dio_client.dart';
import '../presentation/screens/auth/login_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorKey: alice.getNavigatorKey(),
      home: const LoginPage(),
    );
  }
}
