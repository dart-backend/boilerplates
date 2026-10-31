import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_orm/angel3_orm.dart';
import 'package:angel3_static/angel3_static.dart';
import 'package:file/file.dart';

import 'controllers/controllers.dart' as controllers;
import '../models/greeting.dart';

/// The ORM's executor, registered by `config/plugins/orm.dart`; a `503 Service
/// Unavailable` if the server could not connect to the database when it
/// started.
QueryExecutor executorOf(RequestContext req) {
  var container = req.container!;
  if (!container.has<QueryExecutor>()) {
    throw AngelHttpException(
      statusCode: 503,
      message: 'The database is not available.',
    );
  }
  return container.make<QueryExecutor>();
}

/// Put your app routes here!
AngelConfigurer configureServer(FileSystem fileSystem) {
  return (Angel app) async {
    // Typically, you want to mount controllers first, after any global middleware.
    await app.configure(controllers.configureServer);

    // Render `views/hello.jl` when a user visits the application root.
    app.get('/', (req, res) => res.render('hello'));

    app.get('/greetings', (req, res) {
      var executor = executorOf(req);
      var query = GreetingQuery();
      return query.get(executor);
    });

    app.post('/greetings', (req, res) async {
      await req.parseBody();

      if (!req.bodyAsMap.containsKey('message')) {
        throw AngelHttpException.badRequest(message: 'Missing "message".');
      } else {
        var executor = executorOf(req);
        var message = req.bodyAsMap['message'].toString();
        // The ORM fills in only the timestamps given in `values`, so set them.
        var now = DateTime.now();
        var query = GreetingQuery()
          ..values.message = message
          ..values.createdAt = now
          ..values.updatedAt = now;
        var optional = await query.insert(executor);
        return optional.value;
      }
    });

    app.get('/greetings/:message', (req, res) {
      var message = req.params['message'] as String;
      var executor = executorOf(req);
      var query = GreetingQuery()..where!.message.equals(message);
      return query.get(executor);
    });

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
        if (e.statusCode == 404 && req.accepts('text/html', strict: true)) {
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
