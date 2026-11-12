# Angel3 and Kelicap Starter Application

This is a full-stack starter application: an [Angel3 framework](https://angel3-framework.web.app) server, with a web client in [Kelicap](https://github.com/dukefirehawk/kelicap), a Dart web framework derived from AngularDart, which compiles to HTML and JavaScript. The client calls the server's API with [`angel3_client`](https://pub.dev/packages/angel3_client), Angel3's typed client, and both use the same model classes.

## Layout

The project is a [pub workspace](https://dart.dev/tools/pub/workspaces) of three packages:

| Directory | Package | What it is |
| --- | --- | --- |
| `.` | `starter_app` | The Angel3 server: the API under `/api`, which also serves the client |
| `shared/` | `shared` | The models of both, as `Greeting`, made with `angel3_serialize` |
| `client/` | `client` | The Kelicap client: its pages, routes and services |

The server and the client are of one origin, the server's: in development, it forwards the pages to the client's `build_runner serve`; in production, it serves the client as built. So the client needs no CORS, and cookies, as of `angel3_auth`, work.

## Installation & Setup

1. Download and install [Dart](https://dart.dev/get-dart) 3.13 or later.
2. From the project's root, get the packages of all three:

    ```bash
    dart pub get
    ```

### Development

1. In `client/`, build the client, and rebuild it as its files change, on port 8080:

    ```bash
    cd client
    dart run build_runner serve web:8080
    ```

2. In another terminal, from the project's root, start the server in dev mode, *hot-reloaded* on file changes:

    ```bash
    dart --observe bin/dev.dart
    ```

3. Open <http://localhost:3000>, the server's port, not the client's: the server forwards the pages to `build_runner serve`, and answers `/api` itself.

The client's address is `client.dev_server` in `config/default.yaml`.

### Production

Before deploying, check the `jwt_secret` in `config/default.yaml` and `config/production.yaml`: it signs the app's tokens. If it is still `INSECURE_DEFAULT_SECRET`, replace it with a random one (`angel3 key` generates new ones). `angel3 init` already does this for a new project. Keep the secrets out of public repositories, as anyone who knows one can sign tokens the app accepts.

1. Build the client, optimized, into `client/build`:

    ```bash
    cd client
    dart run build_runner build --release -o web:build
    ```

2. Run the server, from the project's root, which serves it:

    ```bash
    ANGEL_ENV=production dart bin/prod.dart
    ```

    Or compile it to a native executable, which needs no Dart SDK to run:

    ```bash
    dart compile exe bin/prod.dart -o server
    ANGEL_ENV=production ./server
    ```

    Run either from the project directory, as the server reads `config/` and `client/build/` from there. The client's directory is `client.build_dir` in `config/default.yaml`.

    The server runs one isolate by default, as the greetings are kept in memory, of each isolate (see `bin/prod.dart`). Once they are in a database, give `-j` to run more.

3. Or run it with [Podman](https://podman.io/). The `Containerfile` builds the client and the native executable, and runs them in a minimal image:

    ```bash
    podman build -t starter_app .
    podman run --rm -p 3000:3000 starter_app
    ```

4. Or run it with Podman Compose:

    ```bash
    # Build the image and start the server in the background
    podman-compose -f contrib/deployment/compose.yaml up --build -d

    # Stop and remove the container
    podman-compose -f contrib/deployment/compose.yaml down
    ```

    See [contrib/deployment/README.md](contrib/deployment/README.md).

## How the client calls the server

The server's `/api/greetings` is an Angel3 service (`lib/src/services/services.dart`). The client reaches it through `angel3_client`, in `client/lib/src/services/greeting_service.dart`:

```dart
// The client of the server, provided to the app in client/web/main.dart.
Angel app = Rest(window.location.origin);

// The service, whose methods take and give the `Greeting` of shared/.
var greetings = app.service<String, Greeting>(
  'api/greetings',
  deserializer: (map) => GreetingSerializer.fromMap(map as Map),
);

await greetings.index();                              // GET    /api/greetings
await greetings.create(Greeting(message: 'Hi'));      // POST   /api/greetings
await greetings.remove(id);                           // DELETE /api/greetings/:id
```

`GreetingService` keeps a `ServiceList` of them, which updates itself as the service is called, and which the greetings page of `client/lib/src/pages/greetings/` shows. An error of the server is thrown as an `AngelHttpException`, with its status code and message. `app.authenticate(...)` logs in with `angel3_auth`, after which the client sends its token with each request.

For live updates, as when another user adds a greeting, use the WebSocket client of [`angel3_websocket`](https://pub.dev/packages/angel3_websocket) (`WebSockets('/ws')`), whose services are the same, and serve WebSockets on the server.

## Adding a model

1. Add it to `shared/lib/src/`, and export it from `shared/lib/shared.dart`. Keep `dart:io`, `angel3_framework` and other server packages out of `shared/`: it is compiled to JavaScript for the client. ORM models, of `@orm`, belong to the server.
2. Generate its serializer, in `shared/`:

    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

3. Serve it on the server, as with `app.use('/api/<name>', ...)`, and call it from a service of the client, as `GreetingService` does.

## Forms in Kelicap

The greetings page binds its input to the component's `message` field with `[(ngModel)]` of [`kelicap_forms`](https://pub.dev/packages/kelicap_forms), and adds the greeting on the form's `(ngSubmit)`, which keeps the page from reloading. `formDirectives` in the component's `directives` provides both.

In code of your own that reads a DOM event, such as a `@HostListener`, take a typed `Event` and read the element in Dart, rather than reading `$event.target.value` in the template: that is dynamic, and fails in a release build (dart2js), although it works in development.

## Resources

Visit the [Developer Guide](https://angel3-docs.dukefirehawk.com/guides) for dozens of guides and resources, including video tutorials, to get up and running as quickly as possible with Angel3.

Examples and complete projects can be found on the [website](https://angel3-framework.web.app/#/examples).

You can also view the [API Documentation](https://pub.dev/documentation/angel3_framework/latest/), the [`angel3_client` documentation](https://pub.dev/packages/angel3_client) and the [Kelicap documentation](https://dukefirehawk.gitbook.io/kelicap-docs).
