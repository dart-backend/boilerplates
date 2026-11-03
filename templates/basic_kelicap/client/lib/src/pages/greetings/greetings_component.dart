import 'dart:async';

import 'package:angel3_client/angel3_client.dart';
import 'package:kelicap/kelicap.dart';
import 'package:kelicap_forms/kelicap_forms.dart';
import 'package:shared/shared.dart';

import '../../services/greeting_service.dart';

/// The greetings of the server, which it lists, adds and removes.
@Component(
  selector: 'greetings',
  styleUrls: ['greetings.css'],
  templateUrl: 'greetings.html',
  directives: [NgFor, NgIf, formDirectives],
)
class GreetingsComponent implements OnInit {
  final GreetingService service;

  /// The message of the new greeting, bound to its input with `[(ngModel)]`.
  String message = '';

  /// The message of the server's last error, if any.
  String? error;

  GreetingsComponent(this.service);

  List<Greeting> get greetings => service.greetings;

  @override
  Future<void> ngOnInit() => _run(service.refresh);

  /// Adds the greeting of [message], on the submit of its form, whose
  /// `ngForm` keeps the page from reloading.
  Future<void> add() async {
    var text = message.trim();
    if (text.isEmpty) return;
    await _run(() => service.add(text));
    if (error == null) message = '';
  }

  Future<void> remove(Greeting greeting) =>
      _run(() => service.remove(greeting));

  /// Runs [call], keeping the message of the error the server answered with,
  /// or saying that it could not be reached.
  Future<void> _run(Future<void> Function() call) async {
    error = null;
    try {
      await call();
    } on AngelHttpException catch (e) {
      error = e.message;
    } on Exception {
      // Such as the `ClientException` of `package:http`, when the server is
      // down.
      error = 'The server could not be reached.';
    }
  }
}
