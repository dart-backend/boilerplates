# Sembast Starter Application for Angel3 Framework

This is a Sembast starter application for [Angel3 framework](https://angel3-framework.web.app) which is a full-stack Web framework in Dart. It serves a REST API of greetings, stored with [`angel3_sembast`](https://pub.dev/packages/angel3_sembast) in [Sembast](https://pub.dev/packages/sembast), a NoSQL database that runs in the server and keeps its data in one file: there is no database server to install.

## Installation & Setup

1. Download and install [Dart](https://dart.dev/get-dart).
2. Optionally, change where the database is kept, in the `sembast` section of the `config/default.yaml` file. The `SEMBAST_PATH` environment variable, if set, overrides it.

   ```yaml
   sembast:
     path: data/app.db
   ```

   The path is relative to the directory the server runs in, and its directory is created if missing. Sembast creates the file, and the `greetings` store, when the first greeting is added, so there are no migrations to run. `data/` is in `.gitignore`.

### One server, one isolate

Sembast keeps the whole database in memory, and writes its changes to its file. Only one isolate may open the file: two would each keep their own copy, and lose or corrupt the other's changes. So:

* `bin/prod.dart` runs the server in one isolate, and refuses `-j` and `--concurrency`, where other Angel3 servers run one per processor.
* Run one server per database file: not several containers or processes over the same file.

This suits small applications, prototypes and tools. To serve more requests at once, or from more than one server, use a database server, as the PostgreSQL or MongoDB templates do.

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

    Run either from the project directory, as the server reads `config/`, `views/` and `web/` from there, and keeps the database in `data/`; to deploy the executable, copy those directories with it. Set `ANGEL_ENV=production` to use the production configuration.

2. Or run it with [Podman](https://podman.io/). The `Containerfile` builds the native executable, and runs it in a minimal image, which keeps the database in `/app/data`. Mount a volume there, so that the data outlives the container:

    ```bash
    podman build -t starter_app .
    podman run --rm -p 3000:3000 -v starter_app_data:/app/data starter_app
    ```

3. Or run it with Podman Compose, which keeps the database in a volume:

    ```bash
    # Build the image and start the server in the background
    podman-compose -f contrib/deployment/compose.yaml up --build -d

    # Stop and remove the container, keeping the database's data
    podman-compose -f contrib/deployment/compose.yaml down

    # ... and also delete the data
    podman-compose -f contrib/deployment/compose.yaml down -v
    ```

    See [contrib/deployment/README.md](contrib/deployment/README.md).

### Backups

The database is one file. Copy it while the server is stopped: Sembast may be writing it while it runs. Restore it the same way, before starting the server.

## Using the API

`SembastService` serves the `greetings` store as a REST API, in `lib/src/services/services.dart`:

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

A greeting's `id` is the key of its record, a number Sembast gives it; an `id` in the body of a request is not stored. If the database could not be opened when the server started, the API answers `503 Service Unavailable`.

The tests in `test/all_test.dart` use an in-memory database (`databaseFactoryMemory`), so they need no file, and test the API itself.

## Resources

Visit the [Developer Guide](https://angel3-docs.dukefirehawk.com/guides) for dozens of guides and resources, including video tutorials, to get up and running as quickly as possible with Angel3.

Examples and complete projects can be found on the [website](https://angel3-framework.web.app/#/examples).

You can also view the [API Documentation](https://pub.dev/documentation/angel3_framework/latest/) and the [`angel3_sembast` documentation](https://pub.dev/packages/angel3_sembast).
