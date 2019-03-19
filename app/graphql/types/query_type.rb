module Types
  class QueryType < Types::BaseObject
    field :school, Types::SchoolType, null: true do
      description "Find a school by ID"
      argument :id, ID, required: true
    end

    def school(id:)
      School.find_by(id: id)
    end
  end
end
