import 'dart:async';

import 'package:angel3_client/angel3_client.dart';
import 'package:collection/collection.dart';
import 'package:kelicap/di.dart';
import 'package:shared/shared.dart';

/// The greetings of the server's `/api/greetings` service, as `Greeting`s of
/// `shared/`, through `angel3_client`'s typed service. The app has one, of its
/// root injector in `web/main.dart`, so its [greetings] are kept between
/// visits of the greetings page.
@Injectable()
class GreetingService {
  final Service<String, Greeting> _greetings;

  /// The greetings, which the service keeps in step with its calls:
  /// [refresh] fills it, [add] adds to it and [remove] removes from it.
  late final ServiceList<String, Greeting> greetings = ServiceList(
    _greetings,
    // Greetings are the same one by their id.
    equality: EqualityBy((Greeting greeting) => greeting.id),
  );

  GreetingService(Angel app)
    : _greetings = app.service<String, Greeting>(
        'api/greetings',
        deserializer: (map) => GreetingSerializer.fromMap(map as Map),
      );

  Future<void> refresh() => _greetings.index();

  Future<void> add(String message) =>
      _greetings.create(Greeting(message: message));

  Future<void> remove(Greeting greeting) => _greetings.remove(greeting.id!);
}
