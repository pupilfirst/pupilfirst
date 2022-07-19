module Types
  class CourseType < Types::BaseObject
    connection_type_class Types::PupilfirstConnection
    field :id, ID, null: false
    field :name, String, null: false
    field :description, String, null: false
    field :ends_at, GraphQL::Types::ISO8601DateTime, null: true
    field :enable_leaderboard, Boolean, null: false
    field :about, String, null: true
    field :public_signup, Boolean, null: false
    field :public_preview, Boolean, null: false
    field :thumbnail, Types::ImageType, null: true
    field :cover, Types::ImageType, null: true
    field :featured, Boolean, null: false
    field :progression_behavior, Types::ProgressionBehaviorType, null: false
    field :progression_limit, Integer, null: true
    field :archived_at, GraphQL::Types::ISO8601DateTime, null: true
    field :highlights, [Types::CourseHighlightType], null: false
    field :processing_url, String, null: true
    field :levels, [Types::LevelType], null: false
    field :student_tags, [String], null: false do
      def authorized?(_object, _args, context)
        context[:current_school_admin].present?
      end
    end

    field :coaches, [Types::UserProxyType], null: false do
      def authorized?(_object, _args, context)
        context[:current_school_admin].present?
      end
    end

    field :cohorts, [Types::CohortType], null: false do
      def authorized?(_object, _args, context)
        context[:current_school_admin].present?
      end
    end

    field :certificates, [Types::CertificateType], null: false do
      def authorized?(_object, _args, context)
        context[:current_school_admin].present?
      end
    end

    def certificates
      BatchLoader::GraphQL
        .for(object.id)
        .batch(default_value: []) do |course_ids, loader|
          Certificate
            .where(course_id: course_ids)
            .each do |certificate|
              loader.call(certificate.course_id) do |memo|
                memo |= [certificate].compact # rubocop:disable Lint/UselessAssignment
              end
            end
        end
    end

    def cohorts
      BatchLoader::GraphQL
        .for(object.id)
        .batch(default_value: []) do |course_ids, loader|
          Cohort
            .where(course_id: course_ids)
            .each do |cohort|
              loader.call(cohort.course_id) do |memo|
                memo |= [cohort].compact # rubocop:disable Lint/UselessAssignment
              end
            end
        end
    end

    def levels
      BatchLoader::GraphQL
        .for(object.id)
        .batch(default_value: []) do |course_ids, loader|
          Level
            .where(course_id: course_ids)
            .each do |level|
              loader.call(level.course_id) do |memo|
                memo |= [level].compact # rubocop:disable Lint/UselessAssignment
              end
            end
        end
    end

    def coaches
      BatchLoader::GraphQL
        .for(object.id)
        .batch(default_value: []) do |course_ids, loader|
          FacultyCohortEnrollment
            .includes(%i[cohort faculty])
            .where(cohort: { course_id: course_ids })
            .each do |enrollment|
              loader.call(enrollment.cohort.course_id) do |memo|
                memo |= [enrollment.faculty].compact # rubocop:disable Lint/UselessAssignment
              end
            end
        end
    end

    def thumbnail
      BatchLoader::GraphQL
        .for(object.id)
        .batch do |course_ids, loader|
          Course
            .includes(thumbnail_attachment: :blob)
            .where(id: course_ids)
            .each do |course|
              if course.cover.attached?
                loader.call(course.id, image_details(course.thumbnail))
              end
            end
        end
    end

    def cover
      BatchLoader::GraphQL
        .for(object.id)
        .batch do |course_ids, loader|
          Course
            .includes(cover_attachment: :blob)
            .where(id: course_ids)
            .each do |course|
              if course.cover.attached?
                loader.call(course.id, image_details(course.cover))
              end
            end
        end
    end

    private

    def image_details(image)
      if image.attached?
        {
          url:
            Rails.application.routes.url_helpers.rails_public_blob_url(image),
          filename: image.filename
        }
      end
    end
  end
end
