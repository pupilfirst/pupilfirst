module Types
  class CoachType < Types::BaseObject
    field :id, ID, null: false
    field :user, Types::UserType, null: false
    field :cohorts, [Types::CohortType], null: false

    def user
      BatchLoader::GraphQL
        .for(object.user_id)
        .batch(default_value: []) do |user_ids, loader|
          User.where(id: user_ids).each { |user| loader.call(user.id, user) }
        end
    end

    def cohorts
      BatchLoader::GraphQL
        .for(object.id)
        .batch(default_value: []) do |coach_ids, loader|
          FacultyCohortEnrollment
            .where(faculty_id: coach_ids)
            .each do |enrollment|
              loader.call(enrollment.faculty_id) do |memo|
                memo |= [enrollment.cohort].compact # rubocop:disable Lint/UselessAssignment
              end
            end
        end
    end
  end
end
