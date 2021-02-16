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

## Browsing GraphQL in development

Visit the `/graphiql` path to browse and interact with all GraphQL queries in the development environment.

**CSP bug**: Pupilfirst LMS uses Content-Security-Policy to prevent execution of unauthorized scripts, and the GraphIQL rubygem doesn't support use of CSP on Rails, yet. [We've created a PR](https://github.com/rmosolgo/graphiql-rails/pull/71) to fix the issue, but until it's merged, one of the gem's files needs to be edited.

You'll need to edit the `show.html.erb` file on the installed gem. It should be at this path:

```
~/.asdf/installs/ruby/2.7.2/lib/ruby/gems/2.7.0/gems/graphiql-rails-1.7.0/app/views/graphiql/rails/editors/show.html.erb
```

Add `nonce: true` to the `javascript_include_tag` call:

```erb
<%= javascript_include_tag("graphiql/rails/application", nonce: true) %>
```

## Updating GraphQL schema

If you make any changes to the GraphQL schema, you'll need to update the `graphql_schema.json` file by running an
introspection query.

With the Pupilfirst server running, run the `graphql-codegen` script.

    yarn run graphql-codegen

It'll visit the local GraphQL end-point which is configured in the `codegen.yml` file, fetch the schema and store it in
the `graphql_schema.json` file.
