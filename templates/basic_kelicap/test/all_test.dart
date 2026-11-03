import 'dart:convert';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_test/angel3_test.dart';
import 'package:shared/shared.dart';
import 'package:starter_app/starter_app.dart';
import 'package:test/test.dart';

// Angel3 also includes facilities to make testing easier.
//
// `package:angel3_test` ships a client that can test
// both plain HTTP and WebSockets.
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

  test('greetings can be added, listed and removed', () async {
    var headers = {'content-type': 'application/json'};
    var created = await client.post(
      Uri.parse('/api/greetings'),
      headers: headers,
      body: jsonEncode(Greeting(message: 'Hello').toJson()),
    );
    expect(created, hasStatus(201));
    // As the client reads it, with the model of `shared/`.
    var greeting = GreetingSerializer.fromMap(jsonDecode(created.body) as Map);
    expect(greeting.message, 'Hello');
    expect(greeting.id, isNotNull);

    var listed = await client.get(Uri.parse('/api/greetings'));
    expect(
      [
        for (var map in jsonDecode(listed.body) as List)
          GreetingSerializer.fromMap(map as Map).message,
      ],
      ['Hello'],
    );

    var removed = await client.delete(
      Uri.parse('/api/greetings/${greeting.id}'),
    );
    expect(removed, hasStatus(200));
  });

  test(
    'an API path of no service is a 404, not a page of the client',
    () async {
      var response = await client.get(Uri.parse('/api/nothing'));
      expect(response, hasStatus(404));
    },
  );
}
