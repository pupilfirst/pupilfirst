module Schools
  module Courses
    class UpdateForm < Reform::Form
      property :course_cover_image, virtual: true, validates: { image: true, file_size: { less_than: 2.megabytes }, allow_blank: true }

      def save
        model.image.attach(course_cover_image) if course_cover_image.present?
      end
    end
  end
end
