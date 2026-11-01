// Declare services here!
import 'dart:async';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_mongo/angel3_mongo.dart';
import 'package:mongo_dart/mongo_dart.dart';

/// Configure our application to use *services*.
/// Services must be wired to the app via `app.use`.
///
/// They provide many benefits, such as instant REST API generation,
/// and respond to both REST and WebSockets.
///
/// Read more here:
/// * https://angel3-docs.dukefirehawk.com/guides/service-basics
/// * https://pub.dev/packages/angel3_mongo
Future configureServer(Angel app) async {
  // The greetings, stored in the `greetings` collection: `GET`, `POST`,
  // `PATCH`, `PUT` and `DELETE` on `/api/greetings` and `/api/greetings/:id`.
  // MongoDB creates the collection when the first greeting is added.
  if (app.container.has<Db>()) {
    var db = app.container.make<Db>();
    app.use('/api/greetings', MongoService(db.collection('greetings')));
  } else {
    // The database could not be opened when the server started (see
    // `config/plugins/mongo.dart`).
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
