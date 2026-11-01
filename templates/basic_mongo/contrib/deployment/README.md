# Running with Podman

[`compose.yaml`](compose.yaml) runs this project and its database in containers, in production mode on port 3000:

* `db`: MongoDB 7, with its data in the `db-data` volume.
* `app`: the server, built from the project's `Containerfile` (a native executable in a `scratch` image), once the database is ready. It serves both its pages and the files of `web/`, which are built into the image.

MongoDB creates the database and its collections when they are first written to, so there are no migrations to run.

## Requirements

* [Podman](https://podman.io/) 4 or later
* [`podman-compose`](https://github.com/containers/podman-compose), or Docker Compose with the Podman socket enabled (`systemctl --user enable --now podman.socket`)

## Usage

From the project's root:

```bash
# Build the image, and start the database and the server
podman-compose -f contrib/deployment/compose.yaml up --build -d

# Follow the server's logs
podman-compose -f contrib/deployment/compose.yaml logs -f app

# Stop and remove the containers, keeping the database's data
podman-compose -f contrib/deployment/compose.yaml down

# ... and also delete the data
podman-compose -f contrib/deployment/compose.yaml down -v
```

Then open <http://localhost:3000>, or the API at <http://localhost:3000/api/greetings>.

`podman compose` (with a space) works too, but it runs whichever compose provider is installed. If that is Docker Compose, it fails with "failed to connect to the docker API" until the Podman socket is enabled.

## Configuration

Set these in the environment, or in a `.env` file in this folder:

| Variable | Default | |
| --- | --- | --- |
| `DB_USERNAME` | `appuser` | The database's user, created by `db` in its `admin` database |
| `DB_PASSWORD` | `App1970` | Its password |
| `APP_PORT` | `3000` | The host port of the server |

`db` creates the user on its first start only. To change it afterwards, delete the data with `down -v`, or change it in the database.

The server reads the `mongo` section of `config/`, except for its `url`, which `compose.yaml` overrides with the `MONGO_URL` environment variable: `mongodb://<user>:<password>@db:27017/appdb?authSource=admin`. In a container, `localhost` is the container itself, so its host is `db`. The password is part of that URL, so one with characters such as `#`, `@` or `/` must be URL-encoded in `DB_PASSWORD` (`%23`, `%40`, `%2F`), and then does not match the password `db` creates: give such a password to `db` and to `MONGO_URL` separately, in `compose.yaml`.

## Notes

* **Secrets**: the image includes `config/`, so its `jwt_secret` values. `angel3 init` generates them for a new project; keep `config/production.yaml` out of public repositories, or replace its secret before deploying. Change the database's default password too.
* **Static files**: the files of `web/` are built into the image, so rebuild it (`up --build`) after changing them. In production, browsers cache them for an hour, and then check them with an ETag. At higher traffic, a reverse proxy such as NGINX can serve them instead.
* **Network**: the server is published on `127.0.0.1` only, and the database not at all. Change `ports` of `app` in `compose.yaml` to `"3000:3000"` to expose the server on every interface.
* **Hardening**: `app` runs with a read-only root filesystem, no Linux capabilities and `no-new-privileges`.
