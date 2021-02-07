---
id: graphql
title: GraphQL API
sidebar_label: GraphQL API
---

Pupilfirst LMS uses a GraphQL API to enable typed communication between the ReScript front-end code and the Rails
server. A few of these GraphQL queries and mutations can be accessed using token-based authentication.

## Documentation

Documentation for queries and mutations that are accessible via token-based authentication can be found here:
https://pupilfirst.github.io/pupilfirst-api-docs

## Token-based authentication

To generate a token on a self-hosted instance, simply call the `user.regenerate_api_token` method, and read the token
by calling `user.api_token`. Make sure to save the token in your application's configuration; it cannot be accessed
again from the database.

To authenticate using the token, pass the token in the `Authorization` header:

```
Authorization: Bearer ACCESS_TOKEN
```

## Updating GraphQL schema

If you make any changes to the GraphQL schema, you'll need to update the `graphql_schema.json` file by running an
introspection query.

With the Pupilfirst server running, run the `graphql-codegen` script.

    yarn run graphql-codegen

It'll visit the local GraphQL end-point which is configured in the `codegen.yml` file, fetch the schema and store it in
the `graphql_schema.json` file.
