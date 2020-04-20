class SvappSchema < GraphQL::Schema
  disable_introspection_entry_points if Rails.env.production?
  mutation(Types::MutationType)
  query(Types::QueryType)
end
