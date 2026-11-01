# Angel3 Application Template with PostgreSQL ORM

This is an [Angel3 framework](https://angel3-framework.web.app) starter application template using PostgreSQL ORM.

## Installation & Setup

1. Download and install [Dart](https://dart.dev/get-dart).
2. Install PostgreSQL 14 or later.
3. Create a new user and database in postgres using `psql` cli. For example:

   ```sql
    postgres=# create user appuser with encrypted password 'App1970#';
    postgres=# create database appdb owner appuser;
   ```

   The user owns the database, so it can create the tables of the migrations. Granting it privileges on the database is not enough: since PostgreSQL 15, only the owner of a database can create tables in its `public` schema.

4. Update the `postgres` section in the `config/default.yaml` file with the newly created user and database name. The `POSTGRES_HOST`, `POSTGRES_USERNAME` and `POSTGRES_PASSWORD` environment variables, if set, override its `host`, `username` and `password`.

   ```yaml
    postgres:
        host: localhost
        port: 5432
        database_name: appdb
        username: appuser
        password: App1970#
        use_ssl: false
        time_zone: UTC
   ```

5. Run the migration to generate `migrations` and `greetings` tables in the database.

    ```bash
    dart bin/migrate.dart up
    ```

### Development

1. Run the following command to start Angel3 server in dev mode to *hot-reloaded* on file changes:

    ```bash
    dart --observe bin/dev.dart
    ```

2. Modify the code and watch the changes applied to the application

3. Insert a message into DB:

    ```bash
    curl -H "Content-Type: application/json" -X POST -d '{"message":"OK_Message" }' "http://localhost:3000/greetings/"
    ```

    or

    ```bash
    curl -X POST -d 'message=OK_Message2' "http://localhost:3000/greetings/"
    ```

4. Query DB:

    ```curl
    http://localhost:3000/greetings/
    ```

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

    In a container, `localhost` is the container itself, so give the database's host with the `POSTGRES_HOST` environment variable, or `host` in `config/`. For a database on the host machine, Podman names it `host.containers.internal`:

    ```bash
    podman run --rm -e POSTGRES_HOST=host.containers.internal starter_app /app/bin/migrate up
    podman run --rm -p 3000:3000 -e POSTGRES_HOST=host.containers.internal starter_app
    ```

    The database must accept connections from the container, not only from `localhost`.

3. Or run it with Podman Compose, together with a PostgreSQL database, which runs the migrations before starting the server:

    ```bash
    # Build the image, and start the database, the migrations and the server
    podman-compose -f contrib/deployment/compose.yaml up --build -d

    # Stop and remove the containers, keeping the database's data
    podman-compose -f contrib/deployment/compose.yaml down

    # ... and also delete the data
    podman-compose -f contrib/deployment/compose.yaml down -v
    ```

    See [contrib/deployment/README.md](contrib/deployment/README.md).

## Resources

Visit the [Developer Guide](https://angel3-docs.dukefirehawk.com/guides) for dozens of guides and resources, including video tutorials, to get up and running as quickly as possible with Angel3.

Examples and complete projects can be found [website](https://angel3-framework.web.app/#/examples).

You can also view the [API Documentation](https://pub.dev/documentation/angel3_framework/latest/).
