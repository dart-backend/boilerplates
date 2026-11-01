import 'dart:async';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_websocket/server.dart';

/// Serves WebSockets at `/ws`, which push the events of every service to the
/// clients connected, and let them call the services.
///
/// With the changefeed of `RethinkService`, a client is told of every change
/// to the `greetings` table, as `api/greetings::created`, `::updated` or
/// `::removed`, whoever made it: a REST request, a WebSocket client, another
/// instance of the server, or a query in the database. A `PATCH` is told as
/// `::updated` too, as the changefeed does not tell the two apart.
///
/// Read more here:
/// * https://pub.dev/packages/angel3_websocket
Future<void> configureServer(Angel app) async {
  var ws = AngelWebSocket(app);

  // Hooks the services, those mounted later too, to broadcast their events.
  await app.configure(ws.configureServer);
  app.all('/ws', ws.handleRequest);
}
