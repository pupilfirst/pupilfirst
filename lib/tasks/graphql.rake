require 'graphql/rake_task'
GraphQL::RakeTask.new(schema_name: 'PupilfirstSchema', json_outfile: 'graphql_schema.json')