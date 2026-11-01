import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_static/angel3_static.dart';
import 'package:file/file.dart';

import 'controllers/controllers.dart' as controllers;
import 'graphql/graphql.dart' as graphql;

// Put your app routes here!
AngelConfigurer configureServer(FileSystem fileSystem) {
  return (Angel app) async {
    // Typically, you want to mount controllers first, after any global middleware.
    await app.configure(controllers.configureServer);

    // Mount our GraphQL routes as well.
    await app.configure(graphql.configureServer);

    // Render `views/hello.jl` when a user visits the application root.
    app.get('/', (req, res) => res.render('hello'));

    // Mount static server at web in development.
    // The `CachingVirtualDirectory` variant of `VirtualDirectory` also sends `Cache-Control` headers.
    //
    // In production, however, prefer serving static files through NGINX or a
    // similar reverse proxy.
    if (!app.environment.isProduction) {
      var vDir = VirtualDirectory(
        app,
        fileSystem,
        source: fileSystem.directory('web'),
      );
      app.fallback(vDir.handleRequest);
    }

    // Throw a 404 if no route matched the request.
    app.fallback((req, res) => throw AngelHttpException.notFound());

    // Set our application up to handle different errors.
    var oldErrorHandler = app.errorHandler;
    app.errorHandler = (e, req, res) async {
      if (req.accepts('text/html', strict: true)) {
        if (e.statusCode == 404) {
          await res.render('error', {
            'message': 'No file exists at ${req.uri}.',
          });
        } else {
          await res.render('error', {'message': e.message});
        }
      } else {
        return await oldErrorHandler(e, req, res);
      }
    };
  };
}
