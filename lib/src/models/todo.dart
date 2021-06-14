import 'package:angel3_serialize/angel3_serialize.dart';
import 'package:graphql_schema2/graphql_schema2.dart';
part 'todo.g.dart';

@graphQLClass
@serializable
abstract class _Todo extends Model {
  String? get text;

  bool? get isComplete;
}
