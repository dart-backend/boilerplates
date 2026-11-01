import 'dart:io';

import 'package:angel3_production/angel3_production.dart';
import 'package:starter_app/starter_app.dart';

// The application runs without a reflector, so it needs no `dart:mirrors`, and
// can be compiled with `dart compile exe`.
//
// These features need a reflector:
// * Controllers, via @Expose() or @ExposeWs()
// * Dependency injection into constructors, in controllers or `container.make`
// * The `ioc` function, in a route without an explicit `injection:`
// * @Hooks() and @Middleware() annotations
//
// To use them, pass a `reflector:` to the `Runner`:
// * a `StaticReflector` of the data that `package:angel3_container_generator`
//   generates, which can be compiled with `dart compile exe`; or
// * the `MirrorsReflector` of `package:angel3_container_mirrors`, which needs
//   the Dart VM, as `dart run`.
//
// The server runs in one isolate, where `Runner` starts one per processor by
// default: Sembast keeps the database in memory and in one file, which only
// one isolate may open, so more would lose or corrupt data. To serve more
// requests at once, use a database server, as the PostgreSQL or MongoDB
// templates do.
void main(List<String> args) {
  if (args.any(
    (arg) =>
        arg == '-j' ||
        arg.startsWith('-j') ||
        arg == '--concurrency' ||
        arg.startsWith('--concurrency='),
  )) {
    stderr.writeln(
      'This server runs in one isolate, as its Sembast database may only be '
      'opened by one: -j and --concurrency are not supported.',
    );
    exitCode = 64;
    return;
  }
  Runner('Starter App', configureServer).run(['--concurrency', '1', ...args]);
}
