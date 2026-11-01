
# Angel3 Starter Application Template

This is an [Angel3 framework](https://angel3-framework.web.app) starter application template.

## Installation & Setup

1. Download and install [Dart](https://dart.dev/get-dart).

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

3. Or run it with Podman Compose, which builds the same image and runs it with a read-only filesystem and no Linux capabilities:

    ```bash
    # Build the image and start the server in the background
    podman-compose -f contrib/deployment/compose.yaml up --build -d

    # Stop and remove the container
    podman-compose -f contrib/deployment/compose.yaml down
    ```

    See [contrib/deployment/README.md](contrib/deployment/README.md).

## Resources

Visit the [Developer Guide](https://angel3-docs.dukefirehawk.com/guides) for dozens of guides and resources, including video tutorials, to get up and running as quickly as possible with Angel3.

Examples and complete projects can be found [website](https://angel3-framework.web.app/#/examples).
