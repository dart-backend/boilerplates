import 'package:kelicap/kelicap.dart';
import 'package:kelicap_router/kelicap_router.dart';

import 'pages/error/not_found_component.template.dart' as not_found_template;
import 'pages/greetings/greetings_component.template.dart'
    as greetings_template;
import 'pages/home/home_component.template.dart' as home_template;

import 'app_route_paths.dart' as paths;

// Define the routing
@Injectable()
class AppRoute {
  RoutePath get home => paths.AppRoutePaths.home;
  RoutePath get greetings => paths.AppRoutePaths.greetings;
  RoutePath get others => paths.AppRoutePaths.others;

  final all = <RouteDefinition>[
    RouteDefinition.redirect(
      path: '',
      redirectTo: paths.AppRoutePaths.home.toUrl(),
    ),
    RouteDefinition(
      routePath: paths.AppRoutePaths.home,
      component: home_template.HomeComponentNgFactory,
    ),
    RouteDefinition(
      routePath: paths.AppRoutePaths.greetings,
      component: greetings_template.GreetingsComponentNgFactory,
    ),
    RouteDefinition(
      routePath: paths.AppRoutePaths.others,
      component: not_found_template.NotFoundComponentNgFactory,
    ),
  ];
}
