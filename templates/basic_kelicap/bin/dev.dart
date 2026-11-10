import 'dart:io';

import 'package:angel3_configuration/angel3_configuration.dart';
import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_hot/angel3_hot.dart';
import 'package:belatuk_pretty_logging/belatuk_pretty_logging.dart';
import 'package:file/local.dart';
import 'package:logging/logging.dart';
import 'package:starter_app/starter_app.dart';

void main() async {
  hierarchicalLoggingEnabled = true;

  // Listen on the `host` and `port` of `config/`. Either can be a String, such
  // as one of an environment variable (`port: $PORT`). They are read once: a
  // change to `config/` reloads the server, which keeps listening on them
  // until it is restarted.
  var config = await loadStandaloneConfiguration(
    const LocalFileSystem(),
    onWarning: stderr.writeln,
  );
  var host = config['host']?.toString() ?? '127.0.0.1';
  var port = int.tryParse('${config['port']}') ?? 3000;

  // Watch the config/ and lib/ directories for changes, and hot-reload the
  // server.
  var hot = HotReloader(() async {
    var logger = Logger.detached('Starter App')
      ..level = Level.ALL
      ..onRecord.listen(prettyLog);
    var app = Angel(logger: logger);
    await app.configure(configureServer);
    return app;
  }, [Directory('config'), Directory('lib')]);

  var server = await hot.startServer(host, port);
  print(
    '[Starter App] server listening at http://${server.address.address}:${server.port}',
  );
}
