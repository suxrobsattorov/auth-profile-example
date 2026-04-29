import 'package:flutter/material.dart';

import 'core/app.dart';
import 'domain/di/injection.dart';
import 'infrastructure/local/token_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();

  final storage = sl<TokenStorage>();
  final hasToken = await storage.hasToken();

  String? phone, countryName, flagEmoji;
  if (hasToken) {
    phone = await storage.getPhone();
    countryName = await storage.getCountryName();
    flagEmoji = await storage.getFlagEmoji();
  }

  final isLoggedIn = hasToken && phone != null;

  runApp(App(
    isLoggedIn: isLoggedIn,
    phone: isLoggedIn ? phone : null,
    countryName: isLoggedIn ? countryName : null,
    flagEmoji: isLoggedIn ? flagEmoji : null,
  ));
}
