import 'dart:async';
import 'dart:io';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_orm/angel3_orm.dart';
import 'package:angel3_orm_postgres/angel3_orm_postgres.dart';
import 'package:postgres/postgres.dart';

Future<void> configureServer(Angel app) async {
  try {
    var connection = await connectToPostgres(app.configuration);

    // Given the endpoint and settings, the executor opens a new connection
    // when this one breaks, as when the database restarts.
    var executor = PostgreSqlExecutor(
      connection,
      endpoint: postgresEndpoint(app.configuration),
      settings: postgresSettings(app.configuration),
      logger: app.logger,
    );

    // The executor closes the connection it uses, which may be a new one.
    app
      ..container.registerSingleton<QueryExecutor>(executor)
      ..shutdownHooks.add((_) => executor.close());
  } catch (e) {
    app.logger.severe("Failed to connect to PostgreSQL. ORM disabled.", e);
  }
}

// PostgreSQL connection, of the `postgres` section of the configuration.
Future<Connection> connectToPostgres(Map configuration) => Connection.open(
  postgresEndpoint(configuration),
  settings: postgresSettings(configuration),
);

// The PostgreSQL server, of the `postgres` section of the configuration. The
// POSTGRES_HOST, POSTGRES_USERNAME and POSTGRES_PASSWORD environment variables
// override its `host`, `username` and `password`, as in a container, so they
// need not be kept in a file.
Endpoint postgresEndpoint(Map configuration) {
  var postgresConfig = configuration['postgres'] as Map? ?? {};
  return Endpoint(
    host:
        Platform.environment['POSTGRES_HOST'] ??
        postgresConfig['host'] as String? ??
        'localhost',
    port: postgresConfig['port'] as int? ?? 5432,
    database:
        postgresConfig['database_name'] as String? ??
        Platform.environment['USER'] ??
        Platform.environment['USERNAME'] ??
        '',
    username:
        Platform.environment['POSTGRES_USERNAME'] ??
        postgresConfig['username'] as String?,
    password:
        Platform.environment['POSTGRES_PASSWORD'] ??
        postgresConfig['password'] as String?,
  );
}

// The settings of a connection, of the `postgres` section of the
// configuration.
ConnectionSettings postgresSettings(Map configuration) {
  var postgresConfig = configuration['postgres'] as Map? ?? {};
  var useSsl = postgresConfig['use_ssl'] as bool? ?? false;
  return ConnectionSettings(
    sslMode: useSsl ? SslMode.require : SslMode.disable,
    timeZone: postgresConfig['time_zone'] as String? ?? 'UTC',
    connectTimeout: Duration(
      seconds: postgresConfig['timeout_in_seconds'] as int? ?? 30,
    ),
  );
}
