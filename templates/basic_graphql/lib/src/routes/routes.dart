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

    // Serve the files of `web/`, such as stylesheets and images. In production,
    // `CachingVirtualDirectory` also sends `Cache-Control` headers, so browsers
    // reuse a file for an hour, and ETags, so they then only download it again
    // if it changed.
    //
    // At higher traffic, a reverse proxy such as NGINX can serve them instead.
    //
    // Read the following two sources for documentation:
    // * https://medium.com/the-angel-framework/serving-static-files-with-the-angel-framework-2ddc7a2b84ae
    // * https://pub.dev/packages/angel3_static
    var vDir = CachingVirtualDirectory(
      app,
      fileSystem,
      source: fileSystem.directory('web'),
      maxAge: 3600,
      onlyInProduction: true,
    );
    app.fallback(vDir.handleRequest);

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
