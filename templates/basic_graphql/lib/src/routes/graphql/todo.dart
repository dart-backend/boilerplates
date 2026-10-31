import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_orm/angel3_orm.dart';
import 'package:graphql_schema2/graphql_schema2.dart';
import 'package:starter_app/src/models/todo.dart';

/// The ORM's executor, registered by `config/plugins/orm.dart`; an error if
/// the server could not connect to the database when it started.
QueryExecutor _executorOf(Angel app) {
  if (!app.container.has<QueryExecutor>()) {
    throw GraphQLException.fromMessage('The database is not available.');
  }
  return app.container.make<QueryExecutor>();
}

/// The id of a to-do, given as a string.
int _idOf(Map<String, dynamic> args) {
  var id = int.tryParse(args['id'] as String);
  if (id == null) {
    throw GraphQLException.fromMessage('Invalid to-do id "${args['id']}".');
  }
  return id;
}

/// Returns fields to be inserted into the query type.
Iterable<GraphQLObjectField> todoQueryFields(Angel app) {
  // The resolvers query the `todos` table with the ORM, and return `Todo`
  // models, whose fields `todoGraphQLType` resolves.
  return [
    field(
      'todos',
      listOf(todoGraphQLType),
      resolve: (_, _) => (TodoQuery()..orderBy('id')).get(_executorOf(app)),
    ),
    field(
      'todo',
      todoGraphQLType,
      inputs: [GraphQLFieldInput('id', graphQLString.nonNullable())],
      resolve: (_, args) async {
        var query = TodoQuery()..where!.id.equals(_idOf(args));
        var todo = await query.getOne(_executorOf(app));
        return todo.isPresent ? todo.value : null;
      },
    ),
  ];
}

/// Returns fields to be inserted into the mutation type.
Iterable<GraphQLObjectField> todoMutationFields(Angel app) {
  var todoInputType = todoGraphQLType.toInputObject('TodoInput');

  return [
    field(
      'createTodo',
      todoGraphQLType,
      inputs: [GraphQLFieldInput('data', todoInputType.nonNullable())],
      resolve: (_, args) async {
        var data = args['data'] as Map;
        // The ORM fills in only the timestamps given in `values`, so set them,
        // as UTC: the database is used at UTC (`time_zone` in config/).
        var now = DateTime.now().toUtc();
        var query = TodoQuery()
          ..values.text = data['text'] as String?
          ..values.isComplete = data['is_complete'] as bool? ?? false
          ..values.createdAt = now
          ..values.updatedAt = now;
        return (await query.insert(_executorOf(app))).value;
      },
    ),
    field(
      'modifyTodo',
      todoGraphQLType,
      inputs: [
        GraphQLFieldInput('id', graphQLString.nonNullable()),
        GraphQLFieldInput('data', todoInputType.nonNullable()),
      ],
      resolve: (_, args) async {
        var data = args['data'] as Map;
        var query = TodoQuery()..where!.id.equals(_idOf(args));
        // Only the fields given are changed.
        if (data.containsKey('text')) {
          query.values.text = data['text'] as String?;
        }
        if (data.containsKey('is_complete')) {
          query.values.isComplete = data['is_complete'] as bool?;
        }
        query.values.updatedAt = DateTime.now().toUtc();

        var todo = await query.updateOne(_executorOf(app));
        if (!todo.isPresent) {
          throw GraphQLException.fromMessage(
            'No to-do has the id ${args['id']}.',
          );
        }
        return todo.value;
      },
    ),
  ];
}
