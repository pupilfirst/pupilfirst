module Types
  class CourseType < Types::BaseObject
    authorize_school_admin =
      proc do
        def authorized?(_object, _args, context)
          context[:current_school_admin].present?
        end
      end
    connection_type_class Types::PupilfirstConnection
    field :id, ID, null: false
    field :name, String, null: false
    field :description, String, null: false
    field :enable_leaderboard, Boolean, null: false
    field :about, String, null: true
    field :public_signup, Boolean, null: false
    field :public_preview, Boolean, null: false
    field :thumbnail, Types::ImageType, null: true
    field :cover, Types::ImageType, null: true
    field :featured, Boolean, null: false
    field :progression_limit, Integer, null: false
    field :sort_index, Integer, null: false
    field :archived_at, GraphQL::Types::ISO8601DateTime, null: true
    field :highlights, [Types::CourseHighlightType], null: false
    field :processing_url, String, null: true
    field :levels, [Types::LevelType], null: false
    field :student_tags, [String], null: false, &authorize_school_admin
    field :coaches, [Types::UserProxyType], null: false, &authorize_school_admin
    field :cohorts, [Types::CohortType], null: false, &authorize_school_admin
    field :default_cohort,
          Types::CohortType,
          null: true,
          &authorize_school_admin
    field :certificates,
          [Types::CertificateType],
          null: false,
          &authorize_school_admin
    field :coaches_count, Integer, null: false, &authorize_school_admin
    field :cohorts_count, Integer, null: false, &authorize_school_admin
    field :levels_count, Integer, null: false, &authorize_school_admin

    def levels_count
      BatchLoader::GraphQL
        .for(object.id)
        .batch(default_value: 0) do |course_ids, loader|
          Level
            .where(course_id: course_ids)
            .group(:course_id)
            .count
            .each do |(course_ids, levels_count)|
              loader.call(course_ids, levels_count)
            end
        end
    end

    def coaches_count
      BatchLoader::GraphQL
        .for(object.id)
        .batch(default_value: 0) do |course_ids, loader|
          Faculty
            .joins(faculty_cohort_enrollments: :cohort)
            .where(cohort: { course_id: course_ids })
            .distinct
            .group(:course_id)
            .count
            .each do |(course_id, coaches_count)|
              loader.call(course_id, coaches_count)
            end
        end
    end

    def cohorts_count
      BatchLoader::GraphQL
        .for(object.id)
        .batch(default_value: 0) do |course_ids, loader|
          Cohort
            .where(course_id: course_ids)
            .group(:course_id)
            .count
            .each do |(course_id, cohorts_count)|
              loader.call(course_id, cohorts_count)
            end
        end
    end

    def default_cohort
      BatchLoader::GraphQL
        .for(object.id)
        .batch do |course_ids, loader|
          Course
            .includes(:default_cohort)
            .where(id: course_ids)
            .each { |course| loader.call(course.id, course.default_cohort) }
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
            .includes(thumbnail_attachment: :blob, cover_attachment: :blob)
            .where(id: course_ids)
            .each do |course|
              if course.thumbnail.attached?
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
