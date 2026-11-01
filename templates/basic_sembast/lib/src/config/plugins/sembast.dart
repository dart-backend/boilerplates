import 'dart:async';
import 'dart:io';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:path/path.dart' as p;
import 'package:sembast/sembast_io.dart';

/// Opens the Sembast database and registers it in the app's container, for
/// the services of `services/services.dart`. If it cannot be opened, the
/// server still starts, and the services answer `503 Service Unavailable`.
///
/// Sembast keeps the database in memory and in one file, which only one
/// isolate may open: the server runs with one (see `bin/prod.dart`).
///
/// A `Database` already registered is kept, as an in-memory one of the tests.
Future<void> configureServer(Angel app) async {
  if (app.container.has<Database>()) return;
  try {
    var db = await openSembastDatabase(app.configuration);

    app
      ..container.registerSingleton<Database>(db)
      ..shutdownHooks.add((_) => db.close());
  } catch (e, st) {
    app.logger.severe(
      'Failed to open the Sembast database. Database disabled.',
      e,
      st,
    );
  }
}

// Sembast database, of `path` in the `sembast` section of the configuration,
// relative to the directory the server runs in. The SEMBAST_PATH environment
// variable overrides it, as in a container. Its directory is created if
// missing.
Future<Database> openSembastDatabase(Map configuration) async {
  var sembastConfig = configuration['sembast'] as Map? ?? {};
  var path =
      Platform.environment['SEMBAST_PATH'] ??
      sembastConfig['path'] as String? ??
      'data/app.db';

  await Directory(p.dirname(path)).create(recursive: true);
  return databaseFactoryIo.openDatabase(path);
}
