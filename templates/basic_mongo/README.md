# MongoDB Starter Application for Angel3 Framework

This is a MongoDB starter application for [Angel3 framework](https://angel3-framework.web.app) which is a full-stack Web framework in Dart. It serves a REST API of greetings, stored in MongoDB with [`angel3_mongo`](https://pub.dev/packages/angel3_mongo).

## Installation & Setup

1. Download and install [Dart](https://dart.dev/get-dart).
2. Install MongoDB 6 or later.
3. Create a user for the application using `mongosh`. For example:

   ```javascript
   use appdb
   db.createUser({ user: "appuser", pwd: "App1970", roles: [{ role: "readWrite", db: "appdb" }] })
   ```

   MongoDB creates the `appdb` database and its `greetings` collection when the first greeting is added, so there are no migrations to run.

4. Update `url` in the `mongo` section of the `config/default.yaml` file with the user, its password and the database. The `MONGO_URL` environment variable, if set, overrides it.

   ```yaml
   mongo:
     url: mongodb://appuser:App1970@localhost:27017/appdb
     timeout_in_seconds: 30
   ```

   A password with characters such as `#`, `@` or `/` must be URL-encoded in it, as `%23`, `%40` or `%2F`. For a user created in another database, such as `admin`, add `?authSource=admin`. A server without authentication needs no user: `mongodb://localhost:27017/appdb`.

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

    In a container, `localhost` is the container itself, so give the database's host with the `MONGO_URL` environment variable, or `url` in `config/`. For a database on the host machine, Podman names it `host.containers.internal`:

    ```bash
    podman run --rm -p 3000:3000 \
      -e MONGO_URL=mongodb://appuser:App1970@host.containers.internal:27017/appdb \
      starter_app
    ```

    The database must accept connections from the container, not only from `localhost`.

3. Or run it with Podman Compose, together with a MongoDB database:

    ```bash
    # Build the image, and start the database and the server
    podman-compose -f contrib/deployment/compose.yaml up --build -d

    # Stop and remove the containers, keeping the database's data
    podman-compose -f contrib/deployment/compose.yaml down

    # ... and also delete the data
    podman-compose -f contrib/deployment/compose.yaml down -v
    ```

    See [contrib/deployment/README.md](contrib/deployment/README.md).

## Using the API

`MongoService` serves the `greetings` collection as a REST API, in `lib/src/services/services.dart`:

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

`MongoService` adds `createdAt` and `updatedAt` to each greeting. If the server could not connect to the database when it started, the API answers `503 Service Unavailable`.

## Resources

Visit the [Developer Guide](https://angel3-docs.dukefirehawk.com/guides) for dozens of guides and resources, including video tutorials, to get up and running as quickly as possible with Angel3.

Examples and complete projects can be found on the [website](https://angel3-framework.web.app/#/examples).

You can also view the [API Documentation](https://pub.dev/documentation/angel3_framework/latest/) and the [`angel3_mongo` documentation](https://pub.dev/packages/angel3_mongo).
