module Types
  class CourseType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :description, String, null: false
    field :ends_at, GraphQL::Types::ISO8601DateTime, null: true
    field :enable_leaderboard, Boolean, null: false
    field :about, String, null: true
    field :public_signup, Boolean, null: false
    field :thumbnail, Types::ImageType, null: true
    field :cover, Types::ImageType, null: true
    field :featured, Boolean, null: false
    field :progression_behavior, Types::ProgressionBehaviorType, null: false
    field :progression_limit, Integer, null: true

    def grades_and_labels
      object.grade_labels.map do |grade, label|
        { grade: grade.to_i, label: label }
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
          url: Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true),
          filename: image.filename
        }
      end
    end
  end
end
