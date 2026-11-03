import 'package:kelicap/kelicap.dart';
import 'package:kelicap_router/kelicap_router.dart';

import 'src/app_route.dart';

@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
  directives: [routerDirectives],
  providers: [ClassProvider(AppRoute)],
  exports: [AppRoute],
)
class AppComponent {
  final AppRoute routes;

  AppComponent(this.routes);
}
