// Custom plugins go here.
import 'dart:async';

import 'package:angel3_framework/angel3_framework.dart';

import 'rethinkdb.dart' as rethinkdb;
import 'websocket.dart' as websocket;

Future configureServer(Angel app) async {
  // Include any plugins you have made here.
  await app.configure(rethinkdb.configureServer);
  await app.configure(websocket.configureServer);
}
