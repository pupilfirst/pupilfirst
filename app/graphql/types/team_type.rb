module Types
  class TeamType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :team_tags, [String], null: false
    field :level_id, ID, null: false
    field :students, [Types::StudentType], null: false
    field :coach_user_ids, [ID], null: false
    field :dropped_out_at, GraphQL::Types::ISO8601DateTime, null: true
    field :access_ends_at, GraphQL::Types::ISO8601DateTime, null: true

    def team_tags
      object.tags.pluck(:name).sort
    end

    def students
      BatchLoader::GraphQL.for(object.id).batch do |team_ids, loader|
        Startup.includes(:founders).where(id: team_ids).each do |team|
          loader.call(team.id, team.founders)
        end
      end
    end

    def coach_user_ids
      object.faculty.map(&:user_id)
    end
  end
end
