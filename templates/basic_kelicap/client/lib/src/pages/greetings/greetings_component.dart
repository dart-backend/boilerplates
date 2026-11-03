import 'dart:async';

import 'package:angel3_client/angel3_client.dart';
import 'package:kelicap/kelicap.dart';
import 'package:shared/shared.dart';
import 'package:web/web.dart';

import '../../services/greeting_service.dart';

/// The greetings of the server, which it lists, adds and removes.
@Component(
  selector: 'greetings',
  styleUrls: ['greetings.css'],
  templateUrl: 'greetings.html',
  directives: [NgFor, NgIf],
  providers: [ClassProvider(GreetingService)],
)
class GreetingsComponent implements OnInit {
  final GreetingService service;

  /// The message of the server's last error, if any.
  String? error;

  GreetingsComponent(this.service);

  List<Greeting> get greetings => service.greetings;

  @override
  Future<void> ngOnInit() => _run(service.refresh);

  /// Adds the greeting of [input], on the submit [event] of its form, which
  /// would otherwise reload the page. The input is read and typed here, in
  /// Dart: a template expression such as `$event.target.value` is dynamic,
  /// which a browser event of `package:web` does not allow once compiled.
  Future<void> add(HTMLInputElement input, Event event) async {
    event.preventDefault();
    var message = input.value.trim();
    if (message.isEmpty) return;
    await _run(() => service.add(message));
    if (error == null) input.value = '';
  }

  Future<void> remove(Greeting greeting) =>
      _run(() => service.remove(greeting));

  /// Runs [call], keeping the message of the error the server answered with.
  Future<void> _run(Future<void> Function() call) async {
    error = null;
    try {
      await call();
    } on AngelHttpException catch (e) {
      error = e.message;
    }
  }
}
