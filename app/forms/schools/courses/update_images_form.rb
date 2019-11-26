module Schools
  module Courses
    class UpdateImagesForm < Reform::Form
      property :course_cover, virtual: true, validates: { image: true, file_size: { less_than: 2.megabytes }, allow_blank: true }
      property :course_thumbnail, virtual: true, validates: { image: true, file_size: { less_than: 2.megabytes }, allow_blank: true }

      def save
        model.cover.attach(course_cover) if course_cover.present?
        model.thumbnail.attach(course_thumbnail) if course_thumbnail.present?
      end
    end
  end
end
