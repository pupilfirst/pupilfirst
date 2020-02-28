module Schools
  module Courses
    class AuthorsPresenter < ApplicationPresenter
      def initialize(view_context, course)
        @course = course
        super(view_context)
      end

      def props
        {
          course_id: @course.id,
          authors: authors
        }
      end

      private

      def authors
        @course.course_authors.includes(user: { avatar_attachment: :blob }).map do |author|
          user = author.user

          user.slice(:name, :email).merge(
            id: author.id,
            avatar_url: user.avatar_url(variant: :thumb)
          )
        end
      end
    end
  end
end
