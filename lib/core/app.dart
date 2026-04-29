import 'package:alice/alice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'constants/constants.dart';
import '../application/auth/auth_bloc.dart';
import '../domain/di/injection.dart';
import '../presentation/screens/auth/login_page.dart';
import '../presentation/screens/main/main_shell_page.dart';

class App extends StatelessWidget {
  final bool isLoggedIn;
  final String? phone;
  final String? countryName;
  final String? flagEmoji;

  const App({
    super.key,
    required this.isLoggedIn,
    this.phone,
    this.countryName,
    this.flagEmoji,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        navigatorKey: sl<Alice>().getNavigatorKey(),
        home: isLoggedIn
            ? MainShellPage(
                phoneNumber: phone!,
                countryName: countryName!,
                flagEmoji: flagEmoji!,
              )
            : const LoginPage(),
      ),
    );
  }
}
