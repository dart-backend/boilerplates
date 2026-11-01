import 'dart:convert';

import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_test/angel3_test.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:starter_app/starter_app.dart';
import 'package:starter_app/src/services/services.dart' as services;
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
    // An in-memory database, which `config/plugins/sembast.dart` keeps, so
    // that the tests write no file.
    app.container.registerSingleton<Database>(
      await databaseFactoryMemory.openDatabase('test.db'),
    );
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

  test('greetings can be added, read, changed and removed', () async {
    var headers = {'content-type': 'application/json'};

    var created = await client.post(
      Uri.parse('/api/greetings'),
      headers: headers,
      body: jsonEncode({'message': 'Hello'}),
    );
    expect(created, hasStatus(201));
    var id = (jsonDecode(created.body) as Map)['id'];

    var listed = await client.get(Uri.parse('/api/greetings'));
    expect(
      listed,
      isJson([
        {'id': id, 'message': 'Hello'},
      ]),
    );

    var modified = await client.patch(
      Uri.parse('/api/greetings/$id'),
      headers: headers,
      body: jsonEncode({'message': 'Hi'}),
    );
    expect(modified, isJson({'id': id, 'message': 'Hi'}));

    var removed = await client.delete(Uri.parse('/api/greetings/$id'));
    expect(removed, hasStatus(200));
    expect(await client.get(Uri.parse('/api/greetings/$id')), hasStatus(404));
  });

  test('without a database, the services are 503', () async {
    // An application whose database could not be opened, so that no
    // `Database` is registered.
    var app = Angel();
    await app.configure(services.configureServer);
    var sembast = await connectTo(app);

    for (var path in ['/api/greetings', '/api/greetings/1']) {
      var response = await sembast.get(Uri.parse(path));
      expect(response, hasStatus(503), reason: path);
      expect(response.body, contains('The database is not available.'));
    }
    await sembast.close();
  });
}
