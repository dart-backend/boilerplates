import 'package:angel3_framework/angel3_framework.dart';
import 'package:graphql_schema2/graphql_schema2.dart';
import 'todo.dart';

/// Creates a GraphQL schema that manages an in-memory store of
/// Todo items.
GraphQLSchema createSchema(Angel app) {
  var queryType = objectType(
    'TodoQuery',
    fields: todoQueryFields(app),
  );

  var mutationType = objectType(
    'TodoMutation',
    fields: todoMutationFields(app),
  );

  return graphQLSchema(
    queryType: queryType,
    mutationType: mutationType,
  );
}
