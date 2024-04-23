module Types
  class CourseExportType < Types::BaseObject
    field :id, ID, null: false
    field :export_type, Types::ExportType, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :tags, [String], null: false
    field :reviewed_only, Boolean, null: false
    field :include_inactive_students, Boolean, null: false
    field :cohorts, [Types::CohortType], null: false
    field :include_user_standings, Boolean, null: false

    def tags
      object.tag_list
    end

    def cohorts
      BatchLoader::GraphQL
        .for(object.id)
        .batch(default_value: []) do |course_export_ids, loader|
          CourseExportsCohort
            .joins(:cohort)
            .where(course_export_id: course_export_ids)
            .each do |course_export_cohort|
              loader.call(course_export_cohort.course_export_id) do |memo|
                memo |= [course_export_cohort.cohort].compact # rubocop:disable Lint/UselessAssignment
              end
            end
        end
    end
  end
end
