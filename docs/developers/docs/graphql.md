---
id: graphql
title: GraphQL
sidebar_label: GraphQL
---

## Updating GraphQL schema

If you make any changes to the GraphQL schema, you'll need to update the `graphql_schema.json` file by running an
introspection query.

With the Pupilfirst server running, run the `graphql-codegen` script.

    $ yarn run graphql-codegen

It'll visit the local GraphQL end-point which is configured in the `codegen.yml` file, fetch the schema and store it in
the `graphql_schema.json` file.
