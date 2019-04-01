module Schools
  module FacultyModule
    class CourseIndexPresenter < ApplicationPresenter
      def initialize(view_context, course)
        super(view_context)

        @course = course
      end

      def react_props
        {
          courseCoachIds: course_faculty_ids,
          startupCoachIds: startup_faculty.pluck(:id),
          schoolCoaches: school_faculty_details,
          courseId: @course.id,
          authenticityToken: view.form_authenticity_token
        }
      end

      private

      def school_faculty
        Faculty.where(school: @course.school).includes(:user, :image_attachment)
      end

      def school_faculty_details
        school_faculty.map do |faculty|
          {
            id: faculty.id,
            name: faculty.name,
            email: faculty.user.email,
            title: faculty.title,
            imageUrl: faculty.image_or_avatar_url
          }
        end
      end

      def startup_faculty
        Faculty.left_joins(startups: :course).where(startups: { courses: { id: @course } })
      end

      def course_faculty_ids
        Faculty.left_joins(:courses).where(courses: { id: @course }).pluck(:id)
      end
    end
  end
end
