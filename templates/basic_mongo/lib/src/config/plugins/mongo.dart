import 'dart:async';
import 'dart:io';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// Opens the MongoDB database and registers its `Db` in the app's container,
/// for the services of `services/services.dart`. If it cannot be opened, the
/// server still starts, and the services answer `503 Service Unavailable`.
Future<void> configureServer(Angel app) async {
  try {
    var db = await connectToMongo(app.configuration);

    app
      ..container.registerSingleton<Db>(db)
      ..shutdownHooks.add((_) => db.close());
  } catch (e, st) {
    app.logger.severe(
      'Failed to connect to MongoDB. Database disabled.',
      e,
      st,
    );
  }
}

// MongoDB database, of `url` in the `mongo` section of the configuration. The
// MONGO_URL environment variable overrides it, as in a container, so that a
// password in it need not be kept in a file.
Future<Db> connectToMongo(Map configuration) async {
  var mongoConfig = configuration['mongo'] as Map? ?? {};
  var url =
      Platform.environment['MONGO_URL'] ??
      mongoConfig['url'] as String? ??
      'mongodb://localhost:27017/appdb';

  // `mongo_dart` has no timeout of its own, so a host that does not answer
  // would hold up the server's start for as long as the system's.
  var timeout = Duration(
    seconds: mongoConfig['timeout_in_seconds'] as int? ?? 30,
  );

  var db = Db(url);
  try {
    await db.open().timeout(timeout);
  } catch (_) {
    try {
      await db.close();
    } catch (_) {}
    rethrow;
  }
  return db;
}
