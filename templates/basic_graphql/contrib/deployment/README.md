# Running with Podman

[`compose.yaml`](compose.yaml) runs this project and its database in containers, in production mode on port 3000:

* `db`: PostgreSQL 17, with its data in the `db-data` volume.
* `migrate`: builds the project's `Containerfile` (native executables in a `scratch` image), runs `bin/migrate up` once the database is ready, and exits.
* `app`: the server, of the same image, once the migrations succeed. It serves both its pages and the files of `web/`, which are built into the image.

## Requirements

* [Podman](https://podman.io/) 4 or later
* [`podman-compose`](https://github.com/containers/podman-compose), or Docker Compose with the Podman socket enabled (`systemctl --user enable --now podman.socket`)

## Usage

From the project's root:

```bash
# Build the image, and start the database, the migrations and the server
podman-compose -f contrib/deployment/compose.yaml up --build -d

# Follow the server's logs
podman-compose -f contrib/deployment/compose.yaml logs -f app

# Stop and remove the containers, keeping the database's data
podman-compose -f contrib/deployment/compose.yaml down

# ... and also delete the data
podman-compose -f contrib/deployment/compose.yaml down -v
```

Then open <http://localhost:3000>.

`podman compose` (with a space) works too, but it runs whichever compose provider is installed. If that is Docker Compose, it fails with "failed to connect to the docker API" until the Podman socket is enabled.

## Configuration

Set these in the environment, or in a `.env` file in this folder:

| Variable | Default | |
|---|---|---|
| `DB_USERNAME` | `appuser` | The database's user, created by `db` |
| `DB_PASSWORD` | `App1970#` | Its password |
| `APP_PORT` | `3000` | The host port of the server |

`db` creates the user and the `appdb` database on its first start only. To change them afterwards, delete the data with `down -v`, or change them in the database.

The server and the migrations read the `postgres` section of `config/`, except for its `host`, `username` and `password`, which `compose.yaml` overrides with the `POSTGRES_HOST`, `POSTGRES_USERNAME` and `POSTGRES_PASSWORD` environment variables. In a container, `localhost` is the container itself, so `POSTGRES_HOST` is `db`.

## Notes

* **Secrets**: the image includes `config/`, so its `jwt_secret` values. `angel3 init` generates them for a new project; keep `config/production.yaml` out of public repositories, or replace its secret before deploying. Change the database's default password too.
* **Static files**: the files of `web/` are built into the image, so rebuild it (`up --build`) after changing them. In production, browsers cache them for an hour, and then check them with an ETag. At higher traffic, a reverse proxy such as NGINX can serve them instead.
* **Network**: the server is published on `127.0.0.1` only, and the database not at all. Change `ports` of `app` in `compose.yaml` to `"3000:3000"` to expose the server on every interface.
* **Hardening**: `app` and `migrate` run with a read-only root filesystem, no Linux capabilities and `no-new-privileges`.
