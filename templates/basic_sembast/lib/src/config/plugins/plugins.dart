// Custom plugins go here.
import 'dart:async';

import 'package:angel3_framework/angel3_framework.dart';

import 'sembast.dart' as sembast;

Future configureServer(Angel app) async {
  // Include any plugins you have made here.
  await app.configure(sembast.configureServer);
}
