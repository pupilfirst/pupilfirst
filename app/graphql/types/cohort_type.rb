module Types
  class CohortType < Types::BaseObject
    # connection_type_class Types::PupilfirstConnection
    field :id, ID, null: false
    field :name, String, null: false
    field :description, String, null: true
    field :ends_at, GraphQL::Types::ISO8601DateTime, null: true
    field :students_count, Integer, null: false
    field :coaches_count, Integer, null: false
    field :course_id, String, null: false
    field :course, Types::CourseType, null: false

    def course
      BatchLoader::GraphQL
        .for(object.id)
        .batch do |cohort_ids, loader|
          Cohort
            .joins(:course)
            .where(id: cohort_ids)
            .each { |cohort| loader.call(cohort.id, cohort.course) }
        end
    end

    def students_count
      BatchLoader::GraphQL
        .for(object.id)
        .batch(default_value: 0) do |cohort_ids, loader|
          Student
            .not_dropped_out
            .where(cohort_id: cohort_ids)
            .group(:cohort_id)
            .count
            .each do |(cohort_id, students_count)|
              loader.call(cohort_id, students_count)
            end
        end
    end

    def coaches_count
      BatchLoader::GraphQL
        .for(object.id)
        .batch(default_value: 0) do |cohort_ids, loader|
          FacultyCohortEnrollment
            .where(cohort_id: cohort_ids)
            .group(:cohort_id)
            .count
            .each do |(cohort_id, coaches_count)|
              loader.call(cohort_id, coaches_count)
            end
        end
    end
  end
end
