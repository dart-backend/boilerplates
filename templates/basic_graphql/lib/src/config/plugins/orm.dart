import 'dart:async';
import 'dart:io';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_orm/angel3_orm.dart';
import 'package:angel3_orm_postgres/angel3_orm_postgres.dart';
import 'package:postgres/postgres.dart';

Future<void> configureServer(Angel app) async {
  try {
    var connection = await connectToPostgres(app.configuration);

    var executor = PostgreSqlExecutor(connection, logger: app.logger);

    app
      ..container.registerSingleton<QueryExecutor>(executor)
      ..shutdownHooks.add((_) => connection.close());
  } catch (e) {
    app.logger.severe("Failed to connect to PostgreSQL. ORM disabled.", e);
  }
}

Future<Connection> connectToPostgres(Map configuration) async {
  var postgresConfig = configuration['postgres'] as Map? ?? {};

  var useSsl = postgresConfig['use_ssl'] as bool? ?? false;
  final connection = await Connection.open(
    Endpoint(
      host: postgresConfig['host'] as String? ?? 'localhost',
      port: postgresConfig['port'] as int? ?? 5432,
      database:
          postgresConfig['database_name'] as String? ??
          Platform.environment['USER'] ??
          Platform.environment['USERNAME'] ??
          '',
      username: postgresConfig['username'] as String?,
      password: postgresConfig['password'] as String?,
    ),
    settings: ConnectionSettings(
      sslMode: useSsl ? SslMode.require : SslMode.disable,
      timeZone: postgresConfig['time_zone'] as String? ?? 'UTC',
      connectTimeout: Duration(
        seconds: postgresConfig['timeout_in_seconds'] as int? ?? 30,
      ),
    ),
  );

  return connection;
}
