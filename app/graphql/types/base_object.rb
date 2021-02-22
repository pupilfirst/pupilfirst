module Types
  class BaseObject < GraphQL::Schema::Object
    connection_type_class PupilfirstConnection
  end
end
