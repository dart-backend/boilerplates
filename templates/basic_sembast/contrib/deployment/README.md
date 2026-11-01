# Running with Podman

[`compose.yaml`](compose.yaml) builds this project with its `Containerfile` (a native executable in a `scratch` image) and runs it in production mode on port 3000. The server serves both its pages and the files of `web/`, which are built into the image, and keeps its Sembast database in a file in the `db-data` volume, at `/app/data/app.db`. There is no database container: Sembast runs in the server.

## Requirements

* [Podman](https://podman.io/) 4 or later
* [`podman-compose`](https://github.com/containers/podman-compose), or Docker Compose with the Podman socket enabled (`systemctl --user enable --now podman.socket`)

## Usage

From the project's root:

```bash
# Build the image and start the server in the background
podman-compose -f contrib/deployment/compose.yaml up --build -d

# Follow its logs
podman-compose -f contrib/deployment/compose.yaml logs -f

# Stop and remove the container, keeping the database's data
podman-compose -f contrib/deployment/compose.yaml down

# ... and also delete the data
podman-compose -f contrib/deployment/compose.yaml down -v
```

Then open <http://localhost:3000>, or the API at <http://localhost:3000/api/greetings>.

`podman compose` (with a space) works too, but it runs whichever compose provider is installed. If that is Docker Compose, it fails with "failed to connect to the docker API" until the Podman socket is enabled.

To publish on another host port, set `APP_PORT`:

```bash
APP_PORT=8080 podman-compose -f contrib/deployment/compose.yaml up --build -d
```

## Notes

* **One container**: only one server, in one isolate, may open the database's file, so do not scale `app` to more than one container. See "One server, one isolate" in the project's README.
* **Backups**: stop the server, and copy the file out of the volume, as with `podman volume export angel3-app_db-data > backup.tar`. Restore it with `podman volume import`, before starting the server.
* **Secrets**: the image includes `config/`, so its `jwt_secret` values. `angel3 init` generates them for a new project; keep `config/production.yaml` out of public repositories, or replace its secret before deploying.
* **Static files**: the files of `web/` are built into the image, so rebuild it (`up --build`) after changing them. In production, browsers cache them for an hour, and then check them with an ETag. At higher traffic, a reverse proxy such as NGINX can serve them instead.
* **Network**: the port is published on `127.0.0.1` only. Change `ports` in `compose.yaml` to `"3000:3000"` to expose it on every interface.
* **Hardening**: the container runs with a read-only root filesystem, but for the database's volume, no Linux capabilities and `no-new-privileges`.
