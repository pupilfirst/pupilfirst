module Types
  class CoachType < Types::BaseObject
    field :id, ID, null: false
    field :user, Types::UserType, null: false
    field :cohorts, [Types::CohortType], null: false do
      argument :course_id, ID, required: true

      def authorized?(_object, _args, context)
        context[:current_school_admin].present?
      end
    end

    field :students, [Types::StudentType], null: false do
      argument :course_id, ID, required: true

      def authorized?(object, args, context)
        course = object.courses.find_by(id: args[:course_id])
        context[:current_school_admin].present? && course.present?
      end
    end

    def user
      BatchLoader::GraphQL
        .for(object.user_id)
        .batch(default_value: []) do |user_ids, loader|
          User.where(id: user_ids).each { |user| loader.call(user.id, user) }
        end
    end

    def students(params)
      object
        .students
        .includes(:cohort)
        .where(cohort_id: Course.find(params[:course_id]).cohorts)
    end

    def cohorts(params)
      object.cohorts.where(course_id: params[:course_id])
    end
  end
end
