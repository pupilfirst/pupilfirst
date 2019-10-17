module Types
  class TeamType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :level_id, ID, null: false
    field :students, [Types::StudentType], null: false

    def team_id
      object.startup_id
    end

    def students
      object.founders
    end
  end
end
