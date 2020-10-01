class PupilfirstSchema < GraphQL::Schema
  disable_introspection_entry_points if Rails.env.production?
  mutation(Types::MutationType)
  query(Types::QueryType)
  use(BatchLoader::GraphQL)
end
