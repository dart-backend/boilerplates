import 'package:angel3_client/angel3_client.dart';
import 'package:angel3_client/browser.dart';
import 'package:client/app_component.template.dart' as ng;
import 'package:kelicap/kelicap.dart';
import 'package:kelicap_router/kelicap_router.dart';
import 'package:web/web.dart';

import 'main.template.dart' as self;

/// The client of the Angel3 server, which serves this app: of its origin, so
/// that the API needs no CORS, and the login cookie of `angel3_auth` works.
Angel angelClient() => Rest(window.location.origin);

@GenerateInjector([
  // `#/greetings`, so that reloading a page needs nothing of the server.
  routerProvidersHash,
  FactoryProvider(Angel, angelClient),
  testabilityProvider,
])
final InjectorFactory rootInjector = self.rootInjector$Injector;

void main() {
  runApp(ng.AppComponentNgFactory, createInjector: rootInjector);
}
