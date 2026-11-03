// This app's route configuration.
import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_proxy/angel3_proxy.dart';
import 'package:angel3_static/angel3_static.dart';
import 'package:file/file.dart';
import 'package:http/io_client.dart';

import 'controllers/controllers.dart' as controllers;

/// Put your app routes here!
///
/// The API is under `/api`; every other path is of the Kelicap client of
/// `client/`, which the server forwards to its `build_runner serve` in
/// development, and serves as built in production, so that both are of one
/// origin: the client needs no CORS, and cookies work.
///
/// See the wiki for information about routing, requests, and responses:
/// * https://angel3-docs.dukefirehawk.com/guides/basic-routing
/// * https://angel3-docs.dukefirehawk.com/guides/requests-and-responses
AngelConfigurer configureServer(FileSystem fileSystem) {
  return (Angel app) async {
    // Typically, you want to mount controllers first, after any global middleware.
    await app.configure(controllers.configureServer);

    // An API path of no route or service is a 404, not a page of the client.
    app.all('/api/*', (req, res) => throw AngelHttpException.notFound());

    var clientConfig = app.configuration['client'] as Map? ?? {};
    if (app.environment.isProduction) {
      // The client as `dart run build_runner build --release -o web:build`
      // wrote it in `client/`. With `CachingVirtualDirectory`, browsers reuse
      // a file for an hour, and then only download it again if it changed.
      var vDir = CachingVirtualDirectory(
        app,
        fileSystem,
        source: fileSystem.directory(
          clientConfig['build_dir'] as String? ?? 'client/build',
        ),
        maxAge: 3600,
        onlyInProduction: true,
      );
      app.fallback(vDir.handleRequest);
    } else {
      // The client as `dart run build_runner serve web:8080` serves it in
      // `client/`, rebuilt as its files change; its WebSockets are forwarded
      // too.
      var proxy = Proxy(
        Uri.parse(
          clientConfig['dev_server'] as String? ?? 'http://127.0.0.1:8080',
        ),
        httpClient: IOClient(),
      );
      app
        ..fallback(proxy.handleRequest)
        ..shutdownHooks.add((_) => proxy.close());
    }

    // Throw a 404 if no route matched the request.
    app.fallback((req, res) => throw AngelHttpException.notFound());
  };
}
