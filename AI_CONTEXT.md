# AI Context: boilerplates

Context for AI coding assistants working in this repository. Read this before making changes.

## What this is

Starter application templates for the [Angel3 framework](https://angel3-framework.web.app). Users rarely clone this repo directly: `angel3 init` (from [angel3-cli](https://github.com/dart-backend/angel3-cli)) downloads it as a GitHub zipball, extracts one `templates/<name>` folder, copies it into a new project, then renames the package and regenerates the JWT secrets. Everything here is therefore shipped to users as-is.

- Repo: https://github.com/dart-backend/boilerplates (contributors work from forks, e.g. `dukefirehawk/boilerplates`)
- Dart SDK: `>=3.13.0 <4.0.0`
- Angel3 packages: `^10.0.0`
- No workspace or Melos: each template is an independent Dart package with its own `pubspec.yaml`

## Templates

| Directory | `angel3 init` menu entry | Database | Codegen |
|---|---|---|---|
| `templates/basic` | Basic | none | none |
| `templates/basic_postgres_orm` | ORM for PostgreSQL | PostgreSQL (`postgres` ^3.5) | `angel3_serialize_generator`, `angel3_orm_generator` |
| `templates/basic_mysql_orm` | ORM for MySQL/MariaDB | MySQL/MariaDB (`mysql_dart` ^4.0) | `angel3_serialize_generator`, `angel3_orm_generator` |
| `templates/basic_graphql` | GraphQL | PostgreSQL | as above, plus `graphql_generator2` |
| `templates/basic_mongo` | MongoDB | MongoDB (`angel3_mongo` ^10.0, `mongo_dart` ^0.10) | none |
| `templates/basic_rethinkdb` | RethinkDB | RethinkDB (`angel3_rethinkdb` ^10.0, `belatuk_rethinkdb` ^2.0) | none |
| `templates/basic_sembast` | Sembast | Sembast, embedded in the server (`angel3_sembast` ^10.0, `sembast` ^3.1) | none |

The mapping from menu entry to folder lives in angel3-cli (`lib/src/commands/init.dart`, the `BoilerplateInfo` constants with `subfolderPath` and `ref: 'master'`). **Renaming or moving a template folder breaks `angel3 init`** until the CLI is updated and released.

## Layout of a template

All templates share the same skeleton; the ORM, GraphQL, MongoDB and RethinkDB ones add to it.

- `pubspec.yaml`: package name is always `starter_app`, `publish_to: none`.
- `lib/starter_app.dart`: `configureServer(Angel app)`, which configures `config`, `services` and `routes` in that order.
- `lib/src/config/config.dart`: loads `config/*.yaml` (`angel3_configuration`) and Jael views, then `plugins/plugins.dart`.
- `lib/src/config/plugins/orm.dart` (ORM/GraphQL): opens the DB connection from the `postgres:` or `mysql:` config section and registers a `QueryExecutor` singleton. On connection failure it logs and continues, so the server still starts without a database.
- `lib/src/config/plugins/mongo.dart` (MongoDB): opens the `Db` from `url` in the `mongo:` config section (or `MONGO_URL`), within `timeout_in_seconds`, and registers it as a singleton. On failure it logs and continues, like `orm.dart`.
- `lib/src/config/plugins/websocket.dart` (RethinkDB): `angel3_websocket` at `/ws`, which broadcasts the events of every service. Clients are told of each change once: `angel3_rethinkdb` ^10.0.1 gives the changefeed's events of the changes the service makes `broadcast: false`, so those are told by the service's own events, and others by the changefeed. Do not add a hook that sets `broadcast: false` on the service's events (as the template did with 10.0.0): clients would then be told of nothing.
- `lib/src/config/plugins/sembast.dart` (Sembast): opens the database file of `path` in the `sembast:` config section (or `SEMBAST_PATH`) with `databaseFactoryIo`, creating its directory, and registers the `Database`; a `Database` already registered is kept, so the tests register an in-memory one (`databaseFactoryMemory`) and test the API itself.
- `bin/prod.dart` (Sembast): runs one isolate (`--concurrency 1`) and refuses `-j`/`--concurrency`, as only one isolate may open a Sembast file. Its `Containerfile` sets `SEMBAST_PATH=/app/data/app.db` with a `VOLUME`, and its compose file has only `app`, with a volume and no database service.
- `lib/src/config/plugins/rethinkdb.dart` (RethinkDB): connects from the `rethinkdb:` config section (or `RETHINKDB_HOST`/`_USERNAME`/`_PASSWORD`), within `timeout_in_seconds`, and registers the `Connection` and a `RethinkDb` as singletons. On failure it logs and continues.
- `lib/src/services/services.dart` (MongoDB, RethinkDB): mounts a `MongoService` or `RethinkService` of the `greetings` collection or table at `/api/greetings`, or, without a database, routes there that throw a 503. In RethinkDB, its `tables` list is what `bin/migrate.dart up` creates.
- `lib/src/routes/routes.dart`: routes, static files of `web/` (with `Cache-Control` and ETags in production), 404 and error pages. In the ORM templates, `executorOf(req)` returns the executor or throws a 503 when the DB is unavailable.
- `lib/src/routes/graphql/` (GraphQL): `graphql.dart` mounts `/graphql` and, outside production, `/graphiql`; `schema.dart` builds the schema; `todo.dart` holds the resolvers, which query the DB through the ORM.
- `lib/src/models/` (ORM/GraphQL): `greeting.dart` (ORM templates) or `todo.dart` (GraphQL), with the committed generated `*.g.dart`. `lib/models.dart` re-exports them.
- `bin/dev.dart`: hot-reloading dev server (`angel3_hot`, run with `dart --observe bin/dev.dart`), listening on `127.0.0.1:3000`.
- `bin/prod.dart`: `angel3_production` `Runner`, with no reflector, so it compiles with `dart compile exe`.
- `bin/migrate.dart` (ORM/GraphQL): `dart bin/migrate.dart up|rollback|reset|refresh`, using `angel3_migration_runner`. (RethinkDB): `dart bin/migrate.dart up` only, which creates the database and the missing tables, as RethinkDB does not create them on first write.
- `config/default.yaml`, `development.yaml`, `production.yaml`: `ANGEL_ENV` selects the environment. DB credentials are in `default.yaml`.
- `views/*.jael`, `web/`: Jael templates and static assets.
- `test/all_test.dart`: `angel3_test` tests that run without binding a port.
- `Containerfile`, `.containerignore`: multi-stage build of a native executable into a `scratch` image, built and run with Podman (`podman build`, `podman run`). The base image is fully qualified (`docker.io/library/dart:stable`), as Podman may refuse or prompt for short names.
- `contrib/deployment/`: a Podman `compose.yaml` that builds the `Containerfile` from the project root (`context: ../..`), and its README. In the ORM and GraphQL templates it also runs the database (PostgreSQL, or MariaDB for MySQL) and a one-off `migrate` service (`bin/migrate up`) before `app`, and points them at the `db` service through the `*_HOST`/`*_USERNAME`/`*_PASSWORD` environment variables. In the MongoDB template it runs MongoDB, with no migrations, and gives `app` a `MONGO_URL` with `authSource=admin`. In the RethinkDB template it runs RethinkDB with `--initial-password`, then `migrate` and `app` like the ORM templates. It ships with the template, so keep it working when the `Containerfile`, port, config or migrations change. The Postgres-based `compose.yaml` files (`basic_postgres_orm`, `basic_graphql`) are identical.
- `README.md`: per-template setup instructions for end users.

## Development Workflow

- **Master Branch**: Stable branch that `angel3 init` downloads (`ref: 'master'` in the CLI). Anything merged here reaches users on their next `angel3 init`.
- **Feature Branches**: Work is done on `feature/<name>` branches (e.g. `feature/upgrade10` for Angel3 10) and PRs target `master`. The old `angel3-basic`, `angel3-orm`, `angel3-orm-mysql` and `angel3-graphql` branches are from the previous one-template-per-branch layout; don't add to them.
- **Checks**: Run these in each template you touched, from that template's directory:

  ```bash
  dart pub get
  dart format --output=none --set-exit-if-changed .
  dart analyze
  dart test
  ```

  The ORM, GraphQL, MongoDB and RethinkDB tests need no running database. Their `test/all_test.dart` checks that the server starts without one, and reports "The database is not available." (a 503 in the ORM, MongoDB and RethinkDB templates, a GraphQL error in GraphQL).
- **Code generation**: After changing a model in an ORM or GraphQL template, run `dart run build_runner build --delete-conflicting-outputs` in that template and commit the regenerated `*.g.dart`. Never edit `*.g.dart` by hand.
- **Running against a database**: Create the user and database described in the template's `README.md`, then `dart bin/migrate.dart up` and `dart --observe bin/dev.dart`.
- **CI**: None. Run the checks locally.
- **Lints**: `package:lints/recommended.yaml`, both at the root and per template.
- **Changelog**: Every user-facing change gets an entry in the affected package's `CHANGELOG.md`, written as plain-English statements about the package (not commit messages). Group a release's entries under `### Breaking changes in X.Y.Z` (each entry prefixed `**Breaking:**`), `### New in X.Y.Z` and `### Fixes in X.Y.Z`, in that order, omitting empty sections. Prefix each fix with a bold area label, e.g. `* **Services:** An invalid id is a 400`. See `packages/framework/CHANGELOG.md` (10.0.0) for the reference style. Commit messages use [Conventional Commits](https://www.conventionalcommits.org/) (`type(scope): description`, `!` for breaking changes).


## Conventions

- Keep changes consistent across templates. Shared files (`bin/dev.dart`, `bin/prod.dart`, `lib/src/config/config.dart`, `views/`, `web/`, `Containerfile`, `.containerignore`, `analysis_options.yaml`) should stay identical, or differ only where a template needs it. The Postgres and MySQL ORM templates mirror each other and differ mainly in `orm.dart`, `migrate.dart`, `config/default.yaml` and dependencies.
- Dependency constraints are aligned across templates (e.g. `build_runner: ^2.15.0`, `test: ^1.31.0`, `lints: ^6.0.0`). Bump them in all the templates together.
- Angel3 major upgrades bump every `angel3_*` dependency and each template's README together, and usually need a matching angel3-cli release.
- Comments in template code are written for end users learning Angel3: explain what and why, and link to the Angel3 docs where useful.
- ORM timestamps are set explicitly in UTC (`DateTime.now().toUtc()`), matching `time_zone: UTC` in the config.

## Gotchas

- **The package name must stay `starter_app`.** angel3-cli renames the project by reading the name from `pubspec.yaml`, then replacing `starter_app` in `pubspec.yaml`, `config/**/*.yaml`, `lib/starter_app.dart` and `package:starter_app/` imports. Files outside those patterns, or references written differently, aren't renamed.
- **`jwt_secret` must stay a single `jwt_secret: ...` line** in `config/default.yaml` and `config/production.yaml`. `angel3 init` deletes every line containing `jwt_secret:` (regex `jwt_secret:[^\n]+\n?`) and appends a generated secret at the end of the file. So the reminder comment above it must never contain `jwt_secret:` (with the colon), and must still read correctly once the secret has moved to the end.
- `config/default.yaml` contains sample DB credentials (`appuser` / `App1970#`). They're placeholders for local development, not secrets. The ORM and GraphQL templates also read the database's host, user and password from the environment: `POSTGRES_HOST`, `POSTGRES_USERNAME`, `POSTGRES_PASSWORD`, or `MYSQL_HOST`, `MYSQL_USERNAME`, `MYSQL_PASSWORD`. The MongoDB template reads its whole connection string from `MONGO_URL`; its sample password is `App1970`, without `#`, as a password in that URL must be URL-encoded. The RethinkDB template reads `RETHINKDB_HOST`, `RETHINKDB_USERNAME` and `RETHINKDB_PASSWORD`; its user is RethinkDB's `admin`.
- `pubspec.lock` is gitignored, so templates resolve to the latest compatible versions when users create a project. Test with a fresh `dart pub upgrade` before merging.
- Generated `*.g.dart` files are committed, so a new project works without running `build_runner`. When a model changes, regenerate them, or `angel3 init` ships stale code.
- `bin/prod.dart` runs without a reflector. Features that need one (controllers via `@Expose`, constructor injection, `ioc`, `@Hooks`/`@Middleware`) won't work unless a reflector is passed, as its comment explains. Don't add `dart:mirrors`-dependent code to templates.
- `.vscode/launch.json` at the root points at `${workspaceRoot}/bin/...`, so it only works when a single template is opened as the workspace.
