import 'dart:io';

import 'package:angel3_configuration/angel3_configuration.dart';
import 'package:belatuk_rethinkdb/belatuk_rethinkdb.dart';
import 'package:file/local.dart';
import 'package:starter_app/src/config/plugins/rethinkdb.dart';
import 'package:starter_app/src/services/services.dart' show tables;

/// Creates the database and the tables of the services, which RethinkDB does
/// not create when they are first written to:
///
///     dart bin/migrate.dart up
///
/// It only adds what is missing, so it can be run again, as after adding a
/// table to `tables` in `lib/src/services/services.dart`.
void main(List<String> args) async {
  if (args.length != 1 || args.first != 'up') {
    stderr.writeln('Usage: dart bin/migrate.dart up');
    exitCode = 64;
    return;
  }

  var configuration = await loadStandaloneConfiguration(
    const LocalFileSystem(),
  );
  var database = databaseName(configuration);
  var r = RethinkDb();
  var connection = await connectToRethinkDb(configuration);

  try {
    var databases = await r.dbList().run(connection) as List;
    if (!databases.contains(database)) {
      await r.dbCreate(database).run(connection);
      print('Created the database "$database".');
    }

    var existing = await r.db(database).tableList().run(connection) as List;
    for (var table in tables) {
      if (!existing.contains(table)) {
        await r.db(database).tableCreate(table).run(connection);
        print('Created the table "$table".');
      }
    }
    print('The database "$database" is up to date.');
  } finally {
    connection.close();
  }
}
