// Declare services here!
import 'dart:async';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_sembast/angel3_sembast.dart';
import 'package:sembast/sembast.dart';

/// Configure our application to use *services*.
/// Services must be wired to the app via `app.use`.
///
/// They provide many benefits, such as instant REST API generation,
/// and respond to both REST and WebSockets.
///
/// Read more here:
/// * https://angel3-docs.dukefirehawk.com/guides/service-basics
/// * https://pub.dev/packages/angel3_sembast
Future configureServer(Angel app) async {
  // The greetings, stored in the `greetings` store of the database: `GET`,
  // `POST`, `PATCH`, `PUT` and `DELETE` on `/api/greetings` and
  // `/api/greetings/:id`. A greeting's id is the key of its record, a number
  // Sembast gives it.
  if (app.container.has<Database>()) {
    var db = app.container.make<Database>();
    app.use('/api/greetings', SembastService(db, store: 'greetings'));
  } else {
    // The database could not be opened when the server started (see
    // `config/plugins/sembast.dart`).
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
