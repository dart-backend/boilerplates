# GraphQL Starter Application for Angel3 Framework

This is a GraphQL starter application for [Angel3 framework](https://angel3-framework.web.app) which is a full-stack Web framework in Dart. It serves a to-do list over GraphQL, stored in PostgreSQL with the Angel3 ORM.

## Installation & Setup

1. Download and install [Dart](https://dart.dev/get-dart).
2. Install PostgreSQL 14 or later.
3. Create a new user and database in postgres using `psql` cli. For example:

   ```sql
    postgres=# create user appuser with encrypted password 'App1970#';
    postgres=# create database appdb owner appuser;
   ```

   The user owns the database, so it can create the tables of the migrations. Granting it privileges on the database is not enough: since PostgreSQL 15, only the owner of a database can create tables in its `public` schema.

4. Update the `postgres` section in the `config/default.yaml` file with the newly created user and database name.

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

5. Run the migration to generate `migrations` and `todos` tables in the database.

    ```bash
    dart bin/migrate.dart up
    ```

### Development

1. Run the following command to start Angel3 server in dev mode to *hot-reloaded* on file changes:

    ```bash
    dart --observe bin/dev.dart
    ```

2. Modify the code and watch the changes applied to the application

### Production

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

2. Or run it with Docker. The `Dockerfile` builds the native executable, and runs it in a minimal image:

    ```bash
    docker build -t starter_app .
    docker run -p 3000:3000 starter_app
    ```

    Run the migrations with the same image, as `docker run --rm starter_app /app/bin/migrate up`. In a container, `localhost` is the container itself, so set the database `host` in `config/` to one the container can reach.

## Using the API

The GraphQL API is served at `/graphql`. In development, explore it with GraphiQL at `http://localhost:3000/graphiql`. For example:

```graphql
mutation {
  createTodo(data: {text: "Write tests"}) { id text is_complete }
}

query {
  todos { id text is_complete created_at }
}
```

`todo(id:)` reads one to-do, and `modifyTodo(id:, data:)` changes the fields given. The resolvers, in `lib/src/routes/graphql/todo.dart`, use the ORM's `TodoQuery`, generated from the model in `lib/src/models/todo.dart` along with its migration and GraphQL type.

## Resources

Visit the [Developer Guide](https://angel3-docs.dukefirehawk.com/guides) for dozens of guides and resources, including video tutorials, to get up and running as quickly as possible with Angel3.

Examples and complete projects can be found [website](https://angel3-framework.web.app/#/examples).

You can also view the [API Documentation](https://pub.dev/documentation/angel3_framework/latest/).
