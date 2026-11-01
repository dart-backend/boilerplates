# Starter Application Templates for Angel3 framework

This repository contains the starter application templates for [Angel3 framework](https://angel3-framework.web.app). `angel3 init` creates a new project from one of them.

## Templates

| Template | `angel3 init` option | Database | Description |
| --- | --- | --- | --- |
| [`basic`](templates/basic) | Basic | none | A basic web application with Jael views and static files |
| [`basic_postgres_orm`](templates/basic_postgres_orm) | ORM for PostgreSQL | PostgreSQL | The basic application, with the Angel3 ORM and migrations |
| [`basic_mysql_orm`](templates/basic_mysql_orm) | ORM for MySQL/MariaDB | MySQL or MariaDB | The basic application, with the Angel3 ORM and migrations |
| [`basic_graphql`](templates/basic_graphql) | GraphQL | PostgreSQL | A to-do list served over GraphQL, stored with the Angel3 ORM |
| [`basic_mongo`](templates/basic_mongo) | MongoDB | MongoDB | The basic application, with a REST API of a MongoDB collection (`angel3_mongo`) |
| [`basic_rethinkdb`](templates/basic_rethinkdb) | RethinkDB | RethinkDB | The basic application, with a REST and WebSocket API of a RethinkDB table, which pushes its changefeed to clients (`angel3_rethinkdb`, `angel3_websocket`) |

Each template is a Dart package that runs on its own, and includes:

* a hot-reloading development server (`bin/dev.dart`) and a production server (`bin/prod.dart`) that compiles with `dart compile exe`
* a `Containerfile`, to build and run the server with [Podman](https://podman.io/)
* a Podman Compose file in `contrib/deployment`, which also runs the database in the ORM, GraphQL, MongoDB and RethinkDB templates, and the migrations in the ORM, GraphQL and RethinkDB ones
* tests that run without a database

## Getting started

1. Install [Dart](https://dart.dev/get-dart) and the Angel3 CLI:

    ```bash
    dart pub global activate angel3_cli
    ```

2. Create a project, and choose a template when asked:

    ```bash
    angel3 init my_app
    ```

    `angel3 init` downloads the templates from this repository's `master` branch, names the project `my_app`, generates its JWT secrets, and runs `dart pub get`.

3. Follow the `README.md` of the new project, which is the template's: [basic](templates/basic/README.md), [ORM for PostgreSQL](templates/basic_postgres_orm/README.md), [ORM for MySQL/MariaDB](templates/basic_mysql_orm/README.md), [GraphQL](templates/basic_graphql/README.md), [MongoDB](templates/basic_mongo/README.md) or [RethinkDB](templates/basic_rethinkdb/README.md).

To try a template without the CLI, run it from its folder in a clone of this repository, as its README describes. For example, with Podman:

```bash
cd templates/basic_postgres_orm
podman-compose -f contrib/deployment/compose.yaml up --build -d
```

Stop it with `podman-compose -f contrib/deployment/compose.yaml down`, adding `-v` to also delete the database's data.

## Security

The templates' `config/default.yaml` and `config/production.yaml` contain `jwt_secret: INSECURE_DEFAULT_SECRET`, and the ORM and GraphQL templates contain a sample database user and password (`appuser` / `App1970#`; `App1970` in the MongoDB template). They are placeholders for local development:

* `angel3 init` replaces the JWT secrets with random ones. In a template run from this repository, replace them before deploying; `angel3 key` generates new ones.
* Change the database's password before deploying, and keep the secrets out of public repositories.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Run these checks in each template you change, from its directory:

```bash
dart pub get
dart format --output=none --set-exit-if-changed .
dart analyze
dart test
```

Changes merged into `master` reach users on their next `angel3 init`.

## Resources

Visit the [Developer Guide](https://angel3-docs.dukefirehawk.com/guides) for dozens of guides and resources, including video tutorials, to get up and running as quickly as possible with Angel3.

Examples and complete projects can be found on the [website](https://angel3-framework.web.app/#/examples).

You can also view the [API Documentation](https://pub.dev/documentation/angel3_framework/latest/).
