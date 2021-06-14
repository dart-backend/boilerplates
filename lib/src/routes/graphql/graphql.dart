import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_graphql/angel3_graphql.dart';
import 'package:graphql_server2/graphql_server2.dart';
import 'schema.dart';

/// Configures the [app] to server GraphQL.
void configureServer(Angel app) {
  // Create a [GraphQL] service instance, using our schema.
  var schema = createSchema(app);
  var graphQL = GraphQL(schema);

  // Mount a handler that responds to GraphQL queries.
  app.all('/graphql', graphQLHttp(graphQL));

  // In development, serve the GraphiQL IDE/editor.
  // More info: https://github.com/graphql/graphiql
  if (!app.environment.isProduction) {
    app.get('/graphiql', graphiQL());
  }
}
