module Types
  class TeamType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :cohort, Types::CohortType, null: false
    field :students, [Types::StudentType], null: false

    def students
      BatchLoader::GraphQL
        .for(object.id)
        .batch do |team_ids, loader|
          Team
            .includes(:founders)
            .where(id: team_ids)
            .each { |team| loader.call(team.id, team.founders) }
        end
    end

    def cohort
      BatchLoader::GraphQL
        .for(object.cohort_id)
        .batch(default_value: []) do |cohort_ids, loader|
          Cohort
            .where(id: cohort_ids)
            .each { |cohort| loader.call(cohort.id, cohort) }
        end
    end
  end
end
