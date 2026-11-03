// Declare services here!
import 'dart:async';

import 'package:angel3_framework/angel3_framework.dart';

/// Configure our application to use *services*.
/// Services must be wired to the app via `app.use`.
///
/// They provide many benefits, such as instant REST API generation,
/// and respond to both REST and WebSockets.
///
/// Read more here:
/// * https://angel3-docs.dukefirehawk.com/guides/service-basics
Future configureServer(Angel app) async {
  // The greetings of the client, `GET`, `POST`, `PATCH`, `PUT` and `DELETE`
  // on `/api/greetings` and `/api/greetings/:id`, which `angel3_client`'s
  // `service('api/greetings')` calls. They are kept in memory, so they are
  // lost when the server stops, and are of one isolate: replace the
  // `MapService` with a service of a database, as of the ORM templates, to keep
  // them, and to run more isolates (`-j`). Their maps are those of
  // the `Greeting` model of `shared/`.
  app.use('/api/greetings', MapService());
}
