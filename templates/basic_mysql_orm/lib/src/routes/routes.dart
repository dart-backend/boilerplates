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
///
/// See the wiki for information about routing, requests, and responses:
/// * https://angel3-docs.dukefirehawk.com/guides/basic-routing
/// * https://angel3-docs.dukefirehawk.com/guides/requests-and-responses
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

      // `message` is a `varChar(255)` column, so reject anything else here
      // with a 400, rather than storing it as text or failing in the database.
      var message = req.bodyAsMap['message'];
      if (message == null) {
        throw AngelHttpException.badRequest(message: 'Missing "message".');
      }
      if (message is! String) {
        throw AngelHttpException.badRequest(
          message: '"message" must be a string.',
        );
      }
      message = message.trim();
      if (message.isEmpty) {
        throw AngelHttpException.badRequest(message: '"message" is blank.');
      }
      // 255 characters, as of the column; `runes` counts characters as the
      // database does, where `length` counts UTF-16 code units.
      if (message.runes.length > 255) {
        throw AngelHttpException.badRequest(
          message: '"message" is longer than 255 characters.',
        );
      }
      // PostgreSQL cannot store a NUL character in text; it is rejected here
      // too, so the two ORM templates accept the same messages.
      if (message.contains('\u0000')) {
        throw AngelHttpException.badRequest(
          message: '"message" contains a NUL character.',
        );
      }

      var executor = executorOf(req);
      // The ORM fills in only the timestamps given in `values`, so set them,
      // as UTC: `MariaDbExecutor` (`config/plugins/orm.dart`) stores them as
      // UTC, and reads them back as UTC.
      var now = DateTime.now().toUtc();
      var query = GreetingQuery()
        ..values.message = message
        ..values.createdAt = now
        ..values.updatedAt = now;
      var optional = await query.insert(executor);
      return optional.value;
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
    //
    // Read the following two sources for documentation:
    // * https://medium.com/the-angel-framework/serving-static-files-with-the-angel-framework-2ddc7a2b84ae
    // * https://pub.dev/packages/angel3_static
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
    //
    // Read the following for documentation:
    // * https://angel3-docs.dukefirehawk.com/guides/error-handling

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
