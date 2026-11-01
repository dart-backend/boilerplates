import 'dart:async';
import 'dart:io';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:belatuk_rethinkdb/belatuk_rethinkdb.dart';

/// Connects to RethinkDB and registers the `Connection`, and the `RethinkDb`
/// that builds queries, in the app's container, for the services of
/// `services/services.dart`. If it cannot connect, the server still starts,
/// and the services answer `503 Service Unavailable`.
Future<void> configureServer(Angel app) async {
  try {
    var connection = await connectToRethinkDb(app.configuration);

    app
      ..container.registerSingleton<RethinkDb>(RethinkDb())
      ..container.registerSingleton<Connection>(connection)
      ..shutdownHooks.add((_) => connection.close());
  } catch (e, st) {
    app.logger.severe(
      'Failed to connect to RethinkDB. Database disabled.',
      e,
      st,
    );
  }
}

// RethinkDB connection, of the `rethinkdb` section of the configuration. The
// RETHINKDB_HOST, RETHINKDB_USERNAME and RETHINKDB_PASSWORD environment
// variables override its `host`, `username` and `password`, as in a container,
// so they need not be kept in a file.
Future<Connection> connectToRethinkDb(Map configuration) async {
  var rethinkConfig = configuration['rethinkdb'] as Map? ?? {};

  // `belatuk_rethinkdb` has no timeout of its own, so a host that does not
  // answer would hold up the server's start for as long as the system's.
  var timeout = Duration(
    seconds: rethinkConfig['timeout_in_seconds'] as int? ?? 30,
  );

  return RethinkDb()
      .connect(
        db: databaseName(configuration),
        host:
            Platform.environment['RETHINKDB_HOST'] ??
            rethinkConfig['host'] as String? ??
            'localhost',
        port: rethinkConfig['port'] as int? ?? 28015,
        user:
            Platform.environment['RETHINKDB_USERNAME'] ??
            rethinkConfig['username'] as String? ??
            'admin',
        password:
            Platform.environment['RETHINKDB_PASSWORD'] ??
            rethinkConfig['password'] as String? ??
            '',
      )
      .timeout(timeout);
}

/// The database of the application's tables, of `database_name` in the
/// `rethinkdb` section of the configuration.
String databaseName(Map configuration) {
  var rethinkConfig = configuration['rethinkdb'] as Map? ?? {};
  return rethinkConfig['database_name'] as String? ?? 'appdb';
}
