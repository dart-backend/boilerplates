import 'package:angel3_serialize/angel3_serialize.dart';

part 'greeting.g.dart';

/// A greeting, as the server stores it and the client shows it. The server
/// gives it its `id`, `createdAt` and `updatedAt`.
@serializable
abstract class _Greeting extends Model {
  @SerializableField(isNullable: false)
  String? get message;
}
