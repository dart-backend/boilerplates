/// The models of the server and the client: plain Dart, so that both can use
/// them. Keep `dart:io`, `angel3_framework` and other server packages out of
/// this package, as the client is compiled to JavaScript.
library;

export 'src/greeting.dart';
