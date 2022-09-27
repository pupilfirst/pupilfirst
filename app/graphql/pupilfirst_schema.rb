class PupilfirstSchema < GraphQL::Schema
  disable_introspection_entry_points if Rails.env.production?
  mutation(Types::MutationType)
  query(Types::QueryType)
  use(BatchLoader::GraphQL)

  def self.unauthorized_field(error)
    raise GraphQL::ExecutionError, "The field #{error.field.graphql_name} on an object of type #{error.type.graphql_name} was hidden due to permissions"
  end
end
