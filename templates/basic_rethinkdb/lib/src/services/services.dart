// Declare services here!
import 'dart:async';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_rethinkdb/angel3_rethinkdb.dart';
import 'package:belatuk_rethinkdb/belatuk_rethinkdb.dart';

/// The tables of the services, which `bin/migrate.dart up` creates, as
/// RethinkDB does not create them when they are first written to.
const tables = ['greetings'];

/// Configure our application to use *services*.
/// Services must be wired to the app via `app.use`.
///
/// They provide many benefits, such as instant REST API generation,
/// and respond to both REST and WebSockets.
///
/// Read more here:
/// * https://angel3-docs.dukefirehawk.com/guides/service-basics
/// * https://pub.dev/packages/angel3_rethinkdb
Future configureServer(Angel app) async {
  // The greetings, stored in the `greetings` table: `GET`, `POST`, `PATCH`,
  // `PUT` and `DELETE` on `/api/greetings` and `/api/greetings/:id`.
  //
  // The service also listens to the table's changefeed, so a change made by
  // anyone, in any instance of the server, fires the `afterCreated`,
  // `afterUpdated` and `afterRemoved` events of
  // `app.findHookedService('api/greetings')`, e.g. to push it to clients over
  // WebSockets with `angel3_websocket`.
  if (app.container.has<Connection>()) {
    var r = app.container.make<RethinkDb>();
    var connection = app.container.make<Connection>();
    app.use('/api/greetings', RethinkService(connection, r.table('greetings')));
  } else {
    // The server could not connect to the database when it started (see
    // `config/plugins/rethinkdb.dart`).
    Never unavailable(RequestContext req, ResponseContext res) =>
        throw AngelHttpException(
          statusCode: 503,
          message: 'The database is not available.',
        );
    app
      ..all('/api/greetings', unavailable)
      ..all('/api/greetings/:id', unavailable);
  }
}
