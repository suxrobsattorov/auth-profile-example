import 'package:alice/alice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../application/auth/auth_bloc.dart';
import '../application/auth/auth_event.dart';
import '../application/auth/auth_state.dart';
import '../domain/di/injection.dart';
import '../presentation/screens/auth/login_page.dart';
import '../presentation/screens/main/main_shell_page.dart';
import 'constants/constants.dart';

class App extends StatefulWidget {
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
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  late final AuthBloc _authBloc;
  late final GlobalKey<NavigatorState>? _navigatorKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authBloc = sl<AuthBloc>();
    _navigatorKey = sl<Alice>().getNavigatorKey();

    if (widget.isLoggedIn) {
      _authBloc.add(const AuthSessionMonitoringStarted());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _authBloc.add(const AuthSessionRefreshRequested(onlyIfDue: true));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            _authBloc.add(const AuthSessionMonitoringStarted());
            return;
          }

          if (state is AuthLoggedOut) {
            _navigatorKey?.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          }
        },
        child: MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          navigatorKey: _navigatorKey,
          home: widget.isLoggedIn
              ? MainShellPage(
                  phoneNumber: widget.phone!,
                  countryName: widget.countryName!,
                  flagEmoji: widget.flagEmoji!,
                )
              : const LoginPage(),
        ),
      ),
    );
  }
}
