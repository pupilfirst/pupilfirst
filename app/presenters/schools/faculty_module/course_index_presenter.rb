module Schools
  module FacultyModule
    class CourseIndexPresenter < ApplicationPresenter
      def initialize(view_context, course)
        super(view_context)

        @course = course
      end

      def props
        {
          course_coaches: course_coaches,
          school_coaches: school_coaches,
          course_id: @course.id,
          authenticity_token: view.form_authenticity_token
        }
      end

      private

      def course_coaches
        @course.faculty
          .includes(user: { avatar_attachment: :blob })
          .map do |coach|
          {
            id: coach.id,
            name: coach.user.name,
            email: coach.user.email,
            title: coach.user.title,
            avatar_url: coach.user.avatar_url(variant: :thumb)
          }
        end
      end

      def school_coaches
        @course.school.faculty
          .where.not(exited: true)
          .includes(:user)
          .map do |coach|
          {
            id: coach.id,
            name: coach.user.name
          }
        end
      end
    end
  end
end
