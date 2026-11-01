# RethinkDB Starter Application for Angel3 Framework

This is a RethinkDB starter application for [Angel3 framework](https://angel3-framework.web.app) which is a full-stack Web framework in Dart. It serves a REST and WebSocket API of greetings, stored in RethinkDB with [`angel3_rethinkdb`](https://pub.dev/packages/angel3_rethinkdb). It follows the table's changefeed, so WebSocket clients are told of every change to it, whoever made it.

## Installation & Setup

1. Download and install [Dart](https://dart.dev/get-dart).
2. Install RethinkDB 2.4 or later.
3. Update the `rethinkdb` section in the `config/default.yaml` file with the server, the database to use and RethinkDB's `admin` user. The `RETHINKDB_HOST`, `RETHINKDB_USERNAME` and `RETHINKDB_PASSWORD` environment variables, if set, override its `host`, `username` and `password`.

   ```yaml
   rethinkdb:
     host: localhost
     port: 28015
     database_name: appdb
     username: admin
     password: ""
     timeout_in_seconds: 30
   ```

   A new RethinkDB server's `admin` user has no password. Set one before exposing the server, as with `rethinkdb --initial-password <password>` on its first start.

4. Create the database and its `greetings` table. RethinkDB does not create them when they are first written to:

    ```bash
    dart bin/migrate.dart up
    ```

    It only adds what is missing, so run it again after adding a table to `tables` in `lib/src/services/services.dart`.

### Development

1. Run the following command to start Angel3 server in dev mode to *hot-reloaded* on file changes:

    ```bash
    dart --observe bin/dev.dart
    ```

2. Modify the code and watch the changes applied to the application

### Production

Before deploying, check the `jwt_secret` in `config/default.yaml` and `config/production.yaml`: it signs the app's tokens. If it is still `INSECURE_DEFAULT_SECRET`, replace it with a random one (`angel3 key` generates new ones). `angel3 init` already does this for a new project. Keep the secrets out of public repositories, as anyone who knows one can sign tokens the app accepts.

1. Run the following command:

    ```bash
    dart bin/prod.dart
    ```

    Or compile it to a native executable, which needs no Dart SDK to run:

    ```bash
    dart compile exe bin/prod.dart -o server
    ANGEL_ENV=production ./server
    ```

    Run either from the project directory, as the server reads `config/`, `views/` and `web/` from there; to deploy the executable, copy those directories with it. Set `ANGEL_ENV=production` to use the production configuration.

2. Or run it with [Podman](https://podman.io/). The `Containerfile` builds the native executable, and runs it in a minimal image:

    ```bash
    podman build -t starter_app .
    podman run --rm -p 3000:3000 starter_app
    ```

    In a container, `localhost` is the container itself, so give the database's host with the `RETHINKDB_HOST` environment variable, or `host` in `config/`. For a database on the host machine, Podman names it `host.containers.internal`:

    ```bash
    podman run --rm -e RETHINKDB_HOST=host.containers.internal starter_app /app/bin/migrate up
    podman run --rm -p 3000:3000 -e RETHINKDB_HOST=host.containers.internal starter_app
    ```

    The database must accept connections from the container, not only from `localhost` (`rethinkdb --bind all`).

3. Or run it with Podman Compose, together with a RethinkDB database, which creates the tables before starting the server:

    ```bash
    # Build the image, and start the database, the migrations and the server
    podman-compose -f contrib/deployment/compose.yaml up --build -d

    # Stop and remove the containers, keeping the database's data
    podman-compose -f contrib/deployment/compose.yaml down

    # ... and also delete the data
    podman-compose -f contrib/deployment/compose.yaml down -v
    ```

    See [contrib/deployment/README.md](contrib/deployment/README.md).

## Using the API

`RethinkService` serves the `greetings` table as a REST API, in `lib/src/services/services.dart`:

```bash
# Add a greeting
curl -X POST -H 'Content-Type: application/json' \
  -d '{"message": "Hello"}' http://localhost:3000/api/greetings

# List them, or find them by a field
curl http://localhost:3000/api/greetings
curl 'http://localhost:3000/api/greetings?message=Hello'

# Read, change or delete one, by the `id` it was given
curl http://localhost:3000/api/greetings/<id>
curl -X PATCH -H 'Content-Type: application/json' \
  -d '{"message": "Hi"}' http://localhost:3000/api/greetings/<id>
curl -X DELETE http://localhost:3000/api/greetings/<id>
```

If the server could not connect to the database when it started, the API answers `503 Service Unavailable`.

### WebSockets

Clients connected to `ws://localhost:3000/ws` are told of every change to the `greetings` table, made through any instance of the server or directly in the database, as JSON events:

```json
{"eventName": "api/greetings::created", "data": {"id": "<id>", "message": "Hello"}}
```

The event names are `api/greetings::created`, `::modified`, `::updated` and `::removed`. A change made through the API is told with the name of its method (`::modified` for a `PATCH`), and one made outside it, as directly in the database, as `::created`, `::updated` or `::removed`, as the changefeed does not tell a modify from an update. Each change is told once. Try it in a browser's console:

```javascript
const ws = new WebSocket('ws://localhost:3000/ws');
ws.onmessage = (m) => console.log(JSON.parse(m.data));
```

Clients can call the service over the socket too, by sending `api/greetings::index`, `::read`, `::create`, `::modify`, `::update` or `::remove`:

```javascript
ws.send(JSON.stringify({eventName: 'api/greetings::create', data: {message: 'Hi'}}));
ws.send(JSON.stringify({eventName: 'api/greetings::index'}));
```

Dart clients can use the `browser` or `io` client of [`angel3_websocket`](https://pub.dev/packages/angel3_websocket), which reconnect by themselves. `lib/src/config/plugins/websocket.dart` serves the WebSockets; every service mounted with `app.use` is served over them too.

On the server, listen to the service's events, which fire for the same changes:

```dart
app.findHookedService('api/greetings')!.afterCreated.listen((event) {
  print('New greeting: ${event.result}');
});
```

## Resources

Visit the [Developer Guide](https://angel3-docs.dukefirehawk.com/guides) for dozens of guides and resources, including video tutorials, to get up and running as quickly as possible with Angel3.

Examples and complete projects can be found on the [website](https://angel3-framework.web.app/#/examples).

You can also view the [API Documentation](https://pub.dev/documentation/angel3_framework/latest/) and the [`angel3_rethinkdb` documentation](https://pub.dev/packages/angel3_rethinkdb).
