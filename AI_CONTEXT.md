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
| `templates/basic_mysql_orm` | ORM for MySQL/MariaDB | MySQL/MariaDB (`mysql_dart` ^3.0) | `angel3_serialize_generator`, `angel3_orm_generator` |
| `templates/basic_graphql` | GraphQL | PostgreSQL | as above, plus `graphql_generator2` |

The mapping from menu entry to folder lives in angel3-cli (`lib/src/commands/init.dart`, the `BoilerplateInfo` constants with `subfolderPath` and `ref: 'master'`). **Renaming or moving a template folder breaks `angel3 init`** until the CLI is updated and released.

## Layout of a template

All templates share the same skeleton; the ORM and GraphQL ones add to it.

- `pubspec.yaml`: package name is always `starter_app`, `publish_to: none`.
- `lib/starter_app.dart`: `configureServer(Angel app)`, which configures `config`, `services` and `routes` in that order.
- `lib/src/config/config.dart`: loads `config/*.yaml` (`angel3_configuration`) and Jael views, then `plugins/plugins.dart`.
- `lib/src/config/plugins/orm.dart` (ORM/GraphQL): opens the DB connection from the `postgres:` or `mysql:` config section and registers a `QueryExecutor` singleton. On connection failure it logs and continues, so the server still starts without a database.
- `lib/src/routes/routes.dart`: routes, static files (dev only), 404 and error pages. In the ORM templates, `executorOf(req)` returns the executor or throws a 503 when the DB is unavailable.
- `lib/src/routes/graphql/` (GraphQL): `graphql.dart` mounts `/graphql` and, outside production, `/graphiql`; `schema.dart` builds the schema; `todo.dart` holds the resolvers, which query the DB through the ORM.
- `lib/src/models/` (ORM/GraphQL): `greeting.dart` (ORM templates) or `todo.dart` (GraphQL), with the committed generated `*.g.dart`. `lib/models.dart` re-exports them.
- `bin/dev.dart`: hot-reloading dev server (`angel3_hot`, run with `dart --observe bin/dev.dart`), listening on `127.0.0.1:3000`.
- `bin/prod.dart`: `angel3_production` `Runner`, with no reflector, so it compiles with `dart compile exe`.
- `bin/migrate.dart` (ORM/GraphQL): `dart bin/migrate.dart up|rollback|reset|refresh`, using `angel3_migration_runner`.
- `config/default.yaml`, `development.yaml`, `production.yaml`: `ANGEL_ENV` selects the environment. DB credentials are in `default.yaml`.
- `views/*.jael`, `web/`: Jael templates and static assets.
- `test/all_test.dart`: `angel3_test` tests that run without binding a port.
- `Dockerfile`, `.dockerignore`: multi-stage build of a native executable into a `scratch` image.
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

  The ORM and GraphQL tests need no running database. Their `test/all_test.dart` checks that the server starts without one, and reports "The database is not available." (a 503 in the ORM templates, a GraphQL error in GraphQL).
- **Code generation**: After changing a model in an ORM or GraphQL template, run `dart run build_runner build --delete-conflicting-outputs` in that template and commit the regenerated `*.g.dart`. Never edit `*.g.dart` by hand.
- **Running against a database**: Create the user and database described in the template's `README.md`, then `dart bin/migrate.dart up` and `dart --observe bin/dev.dart`.
- **CI**: None. Run the checks locally.
- **Lints**: `package:lints/recommended.yaml`, both at the root and per template.
- **Changelog**: Every user-facing change gets an entry in the affected package's `CHANGELOG.md`, written as plain-English statements about the package (not commit messages). Group a release's entries under `### Breaking changes in X.Y.Z` (each entry prefixed `**Breaking:**`), `### New in X.Y.Z` and `### Fixes in X.Y.Z`, in that order, omitting empty sections. Prefix each fix with a bold area label, e.g. `* **Services:** An invalid id is a 400`. See `packages/framework/CHANGELOG.md` (10.0.0) for the reference style. Commit messages use [Conventional Commits](https://www.conventionalcommits.org/) (`type(scope): description`, `!` for breaking changes).


## Conventions

- Keep changes consistent across templates. Shared files (`bin/dev.dart`, `bin/prod.dart`, `lib/src/config/config.dart`, `views/`, `web/`, `Dockerfile`, `analysis_options.yaml`) should stay identical, or differ only where a template needs it. The Postgres and MySQL ORM templates mirror each other and differ mainly in `orm.dart`, `migrate.dart`, `config/default.yaml` and dependencies.
- Dependency constraints are aligned across templates (e.g. `build_runner: ^2.15.0`, `test: ^1.31.0`, `lints: ^6.0.0`). Bump them in all four templates together.
- Angel3 major upgrades bump every `angel3_*` dependency and each template's README together, and usually need a matching angel3-cli release.
- Comments in template code are written for end users learning Angel3: explain what and why, and link to the Angel3 docs where useful.
- ORM timestamps are set explicitly in UTC (`DateTime.now().toUtc()`), matching `time_zone: UTC` in the config.

## Gotchas

- **The package name must stay `starter_app`.** angel3-cli renames the project by reading the name from `pubspec.yaml`, then replacing `starter_app` in `pubspec.yaml`, `config/**/*.yaml`, `lib/starter_app.dart` and `package:starter_app/` imports. Files outside those patterns, or references written differently, aren't renamed.
- **`jwt_secret` must stay a single `jwt_secret: ...` line** in `config/default.yaml` and `config/production.yaml`. `angel3 init` replaces it with a regex and appends a generated secret.
- `config/default.yaml` contains sample DB credentials (`appuser` / `App1970#`). They're placeholders for local development, not secrets. The MySQL template also reads `MYSQL_USERNAME` and `MYSQL_PASSWORD` from the environment.
- `pubspec.lock` is gitignored, so templates resolve to the latest compatible versions when users create a project. Test with a fresh `dart pub upgrade` before merging.
- Generated `*.g.dart` files are committed, so a new project works without running `build_runner`. When a model changes, regenerate them, or `angel3 init` ships stale code.
- `bin/prod.dart` runs without a reflector. Features that need one (controllers via `@Expose`, constructor injection, `ioc`, `@Hooks`/`@Middleware`) won't work unless a reflector is passed, as its comment explains. Don't add `dart:mirrors`-dependent code to templates.
- `.vscode/launch.json` at the root points at `${workspaceRoot}/bin/...`, so it only works when a single template is opened as the workspace.
