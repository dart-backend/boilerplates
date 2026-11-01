import 'dart:convert';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_test/angel3_test.dart';
import 'package:starter_app/starter_app.dart';
import 'package:starter_app/src/routes/routes.dart' show executorOf;
import 'package:test/test.dart';

// Angel also includes facilities to make testing easier.
//
// `package:angel_test` ships a client that can test
// both plain HTTP and WebSockets.
//
// Tests do not require your server to actually be mounted on a port,
// so they will run faster than they would in other frameworks, where you
// would have to first bind a socket, and then account for network latency.
void main() async {
  late TestClient client;

  setUp(() async {
    var app = Angel();
    await app.configure(configureServer);

    client = await connectTo(app);
  });

  tearDown(() async {
    await client.close();
  });

  test('index returns 200', () async {
    // Request a resource at the given path.
    var response = await client.get(Uri.parse('/'));

    // Expect a 200 response.
    expect(response, hasStatus(200));
  });

  test('an invalid greeting is a 400', () async {
    // The message is checked before the database is used, so these need no
    // database.
    for (var body in <Map<String, dynamic>>[
      {},
      {'message': null},
      {'message': 42},
      {'message': '   '},
      {'message': 'a' * 256},
      {'message': 'hi\u0000there'},
    ]) {
      var response = await client.post(
        Uri.parse('/greetings'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode(body),
      );
      expect(response, hasStatus(400), reason: '$body');
    }
  });

  test('without a database, the ORM routes are 503', () async {
    // An application without the ORM's executor, as when the server could
    // not connect to the database.
    var app = Angel()..get('/orm', (req, res) => executorOf(req));
    var orm = await connectTo(app);

    var response = await orm.get(Uri.parse('/orm'));
    expect(response, hasStatus(503));
    expect(response.body, contains('The database is not available.'));
    await orm.close();
  });
}
