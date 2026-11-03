import 'package:angel3_client/browser.dart';
import 'package:client/app_component.template.dart' as ng;
import 'package:client/src/services/greeting_service.dart';
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
  // One for the app, rather than one for each visit of the greetings page,
  // each of which would add a service to `Rest`, and listeners to it.
  ClassProvider(GreetingService),
  testabilityProvider,
])
final InjectorFactory rootInjector = self.rootInjector$Injector;

void main() {
  runApp(ng.AppComponentNgFactory, createInjector: rootInjector);
}
