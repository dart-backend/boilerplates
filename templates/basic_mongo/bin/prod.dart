import 'dart:io';

import 'package:angel3_configuration/angel3_configuration.dart';
import 'package:angel3_production/angel3_production.dart';
import 'package:file/local.dart';
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
void main(List<String> args) async => Runner(
  'Starter App',
  configureServer,
).run(await _withConfiguredAddress(args));

/// Listens on the `host` and `port` of `config/`, unless `-a`/`--address` or
/// `-p`/`--port` is given, as the last value of an option is the one used.
Future<List<String>> _withConfiguredAddress(List<String> args) async {
  var config = await loadStandaloneConfiguration(
    const LocalFileSystem(),
    onWarning: stderr.writeln,
  );
  return [
    '--address',
    config['host']?.toString() ?? '127.0.0.1',
    '--port',
    '${config['port'] ?? 3000}',
    ...args,
  ];
}
