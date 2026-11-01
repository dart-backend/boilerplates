import 'dart:io';

import 'package:belatuk_pretty_logging/belatuk_pretty_logging.dart';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_hot/angel3_hot.dart';
import 'package:logging/logging.dart';
import 'package:starter_app/starter_app.dart';

void main() async {
  // Watch the config/ and web/ directories for changes, and hot-reload the server.
  hierarchicalLoggingEnabled = true;

  var hot = HotReloader(() async {
    var logger = Logger.detached('Starter App')
      ..level = Level.ALL
      ..onRecord.listen(prettyLog);
    var app = Angel(logger: logger);
    await app.configure(configureServer);
    return app;
  }, [Directory('config'), Directory('lib')]);

  var server = await hot.startServer('127.0.0.1', 3000);
  print(
    '[Starter App] server listening at http://${server.address.address}:${server.port}',
  );
}
