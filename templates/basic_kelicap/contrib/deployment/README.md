# Running with Podman

[`compose.yaml`](compose.yaml) builds this project with its `Containerfile`, which builds the Kelicap client and a native executable of the server into a `scratch` image, and runs it in production mode on port 3000. The server serves both its API and the client, built into the image.

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

# Stop and remove the container
podman-compose -f contrib/deployment/compose.yaml down
```

Then open <http://localhost:3000>.

`podman compose` (with a space) works too, but it runs whichever compose provider is installed. If that is Docker Compose, it fails with "failed to connect to the docker API" until the Podman socket is enabled.

To publish on another host port, set `APP_PORT`:

```bash
APP_PORT=8080 podman-compose -f contrib/deployment/compose.yaml up --build -d
```

## Notes

* **Secrets**: the image includes `config/`, so its `jwt_secret` values. `angel3 init` generates them for a new project; keep `config/production.yaml` out of public repositories, or replace its secret before deploying.
* **Client**: the client is built into the image, so rebuild it (`up --build`) after changing it. In production, browsers cache its files for an hour, and then check them with an ETag.
* **Greetings**: they are kept in the server's memory, so they are lost when the container stops.
* **Network**: the port is published on `127.0.0.1` only. Change `ports` in `compose.yaml` to `"3000:3000"` to expose it on every interface.
* **Hardening**: the container runs with a read-only root filesystem, no Linux capabilities and `no-new-privileges`. The server only listens and logs to stdout, so it needs nothing more.
