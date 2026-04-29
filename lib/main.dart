import 'package:flutter/material.dart';

import 'core/app.dart';
import 'domain/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const App());
}
