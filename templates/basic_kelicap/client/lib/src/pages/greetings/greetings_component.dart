import 'dart:async';

import 'package:angel3_client/angel3_client.dart';
import 'package:http/http.dart' show ClientException;
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

  /// Whether a greeting is being added, during which its button is disabled,
  /// and another submit is ignored.
  bool adding = false;

  GreetingsComponent(this.service);

  List<Greeting> get greetings => service.greetings;

  @override
  Future<void> ngOnInit() => _run(service.refresh);

  /// Adds the greeting of [message], on the submit of its form, whose
  /// `ngForm` keeps the page from reloading.
  Future<void> add() async {
    var text = message.trim();
    if (text.isEmpty || adding) return;
    adding = true;
    try {
      // Keeps the input of a failed greeting, and what the user typed while it
      // was being added.
      if (await _run(() => service.add(text)) && message.trim() == text) {
        message = '';
      }
    } finally {
      adding = false;
    }
  }

  Future<void> remove(Greeting greeting) =>
      _run(() => service.remove(greeting));

  /// Runs [call], and returns whether it succeeded. Otherwise it keeps, as
  /// [error], the message of the error the server answered with, or says that
  /// it could not be reached.
  Future<bool> _run(Future<void> Function() call) async {
    error = null;
    try {
      await call();
      return true;
    } on AngelHttpException catch (e) {
      // Also a response that is not JSON, such as an HTML page of a proxy.
      error = e.message;
    } on ClientException {
      // The server is down, or the network is.
      error = 'The server could not be reached.';
    } catch (_) {
      // A bug: shown, and rethrown, so that it is reported in the console.
      error = 'Something went wrong.';
      rethrow;
    }
    return false;
  }
}
