module Schools
  module Courses
    class IndexPresenter < ApplicationPresenter
      def initialize(view_context, course)
        @course = course

        super(view_context)
      end

      def props
        { selected_course: selected_course_details }
      end

      private

      def selected_course_details
        return if @course.blank?

        {
          id: @course.id,
          name: @course.name,
          description: @course.description,
          ends_at: @course.ends_at,
          enable_leaderboard: @course.enable_leaderboard,
          about: @course.about,
          public_signup: @course.public_signup,
          thumbnail: thumbnail,
          cover: cover,
          featured: @course.featured,
          progression_behavior: @course.progression_behavior,
          progression_limit: @course.progression_limit,
          archived_at: @course.archived_at
        }
      end

      def cover
        image_details(@course.cover)
      end

      def thumbnail
        image_details(@course.thumbnail)
      end

      def image_details(image)
        if image.attached?
          {
            url:
              Rails.application.routes.url_helpers.rails_blob_path(
                image,
                only_path: true
              ),
            filename: image.filename
          }
        end
      end
    end
  end
end
