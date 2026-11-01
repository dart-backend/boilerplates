import 'dart:async';
import 'dart:io';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_orm/angel3_orm.dart';
import 'package:angel3_orm_mysql/angel3_orm_mysql.dart';
import 'package:mysql_dart/mysql_dart.dart';

Future<void> configureServer(Angel app) async {
  try {
    var connection = await connectToMySQL(app.configuration);

    // `MariaDbExecutor` works with both MariaDB and MySQL, and stores a
    // `DateTime` as UTC. `MySqlExecutor` stores it as local time instead, so
    // use one of them for a database, not both.
    var executor = MariaDbExecutor(connection, logger: app.logger);

    // Close the executor rather than the connection: it waits for the ORM's
    // queries still running.
    app
      ..container.registerSingleton<QueryExecutor>(executor)
      ..shutdownHooks.add((_) => executor.close());
  } catch (e, st) {
    app.logger.severe("Failed to connect to MySQL. ORM disabled.", e, st);
  }
}

// MariaDB or MySQL connection, of the `mysql` section of the configuration.
// The MYSQL_HOST, MYSQL_USERNAME and MYSQL_PASSWORD environment variables
// override its `host`, `username` and `password`, as in a container, so they
// need not be kept in a file.
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

  var databaseName = mysqlDbConfig['database_name'] as String?;
  if (databaseName == null || databaseName.isEmpty) {
    throw StateError(
      'No MySQL database: set `mysql.database_name` in config/default.yaml.',
    );
  }

  // The timeout covers opening the socket, the TLS handshake and logging in.
  var timeout = Duration(
    seconds: mysqlDbConfig['timeout_in_seconds'] as int? ?? 30,
  );
  var stopwatch = Stopwatch()..start();

  var connection = await MySQLConnection.createConnection(
    databaseName: databaseName,
    port: mysqlDbConfig['port'] as int? ?? 3306,
    host:
        Platform.environment['MYSQL_HOST'] ??
        mysqlDbConfig['host'] as String? ??
        'localhost',
    userName: userName,
    password:
        Platform.environment['MYSQL_PASSWORD'] ??
        mysqlDbConfig['password'] as String? ??
        '',
    secure: mysqlDbConfig['use_ssl'] as bool? ?? false,
    // MySQL 8 users log in with `caching_sha2_password` by default, which,
    // without TLS (`use_ssl`), needs the server's RSA public key to send the
    // password. Either set `server_public_key` to its PEM, or allow fetching it
    // from the server, which is only safe on a trusted network.
    serverPublicKey: mysqlDbConfig['server_public_key'] as String?,
    allowPublicKeyRetrieval:
        mysqlDbConfig['allow_public_key_retrieval'] as bool? ?? false,
    // With TLS, the server's certificate must chain to a trusted root and name
    // `host`. A server in a container or on the same host has the self-signed one
    // MySQL and MariaDB generate: set `verify_server_certificate: false` for
    // it. The traffic is still encrypted.
    verifyServerCertificate:
        mysqlDbConfig['verify_server_certificate'] as bool? ?? true,
    socketTimeout: timeout,
  );

  // The rest of the timeout covers the TLS handshake and logging in. A
  // connection that fails or times out is closed by `mysql_dart`.
  var remaining = timeout - stopwatch.elapsed;
  await connection.connect(
    timeoutMs: remaining.isNegative ? 0 : remaining.inMilliseconds,
  );

  return connection;
}
