import 'package:angel3_migration/angel3_migration.dart';
import 'package:angel3_orm/angel3_orm.dart';
import 'package:angel3_serialize/angel3_serialize.dart';
import 'package:graphql_schema2/graphql_schema2.dart';
import 'package:optional/optional.dart';
part 'todo.g.dart';

/// A to-do item, stored in the `todos` table, and served as the GraphQL type
/// `Todo` (`todoGraphQLType`).
@graphQLClass
@serializable
@orm
abstract class _Todo extends Model {
  String? get text;

  bool? get isComplete;
}
