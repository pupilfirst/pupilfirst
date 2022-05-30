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
    field :certificates, [Types::CertificateType], null: false do
      def authorized?(_object, _args, context)
        context[:current_school_admin].present?
      end
    end

    def cover
      image_details(object.cover)
    end

    def thumbnail
      image_details(object.thumbnail)
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
  end
end
