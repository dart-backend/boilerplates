import 'dart:async';
import 'dart:io';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_orm/angel3_orm.dart';
import 'package:angel3_orm_mysql/angel3_orm_mysql.dart';
import 'package:mysql_dart/mysql_dart.dart';

// For MariaDb
Future<void> configureServer(Angel app) async {
  try {
    var connection = await connectToMySQL(app.configuration);
    var executor = MySqlExecutor(connection, logger: app.logger);

    app
      ..container.registerSingleton<QueryExecutor>(executor)
      ..shutdownHooks.add((_) => connection.close());
  } catch (e) {
    app.logger.severe("Failed to connect to MySQL. ORM disabled.", e);
  }
}

// MariaDB or MySQL connection, of the `mysql` section of the configuration.
// The MYSQL_USERNAME and MYSQL_PASSWORD environment variables override its
// `username` and `password`, so they need not be kept in a file.
Future<MySQLConnection> connectToMySQL(Map configuration) async {
  var mysqlDbConfig = configuration['mysql'] as Map? ?? {};

  var userName =
      Platform.environment['MYSQL_USERNAME'] ??
      mysqlDbConfig['username'] as String?;
  if (userName == null) {
    throw StateError(
      'No MySQL user: set `mysql.username` in config/default.yaml, or the '
      'MYSQL_USERNAME environment variable.',
    );
  }

  var connection = await MySQLConnection.createConnection(
    databaseName:
        mysqlDbConfig['database_name'] as String? ??
        Platform.environment['USER'] ??
        Platform.environment['USERNAME'] ??
        '',
    port: mysqlDbConfig['port'] as int? ?? 3306,
    host: mysqlDbConfig['host'] as String? ?? 'localhost',
    userName: userName,
    password:
        Platform.environment['MYSQL_PASSWORD'] ??
        mysqlDbConfig['password'] as String? ??
        '',
    secure: mysqlDbConfig['use_ssl'] as bool? ?? false,
  );

  var timeoutInSeconds = mysqlDbConfig['timeout_in_seconds'] as int? ?? 30;
  await connection.connect(timeoutMs: timeoutInSeconds * 1000);

  return connection;
}
