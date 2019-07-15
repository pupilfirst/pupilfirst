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
        @course.school.faculty.where.not(exited: true).includes(:startups, user: { avatar_attachment: :blob })
      end

      def school_faculty_details
        school_faculty.map do |faculty|
          {
            id: faculty.id,
            name: faculty.user.name,
            email: faculty.user.email,
            title: faculty.user.title,
            imageUrl: faculty.user.image_or_avatar_url,
            teams: faculty_team_details(faculty)
          }
        end
      end

      def faculty_team_details(faculty)
        if faculty.startups.present?
          faculty.startups.map { |startup| { name: startup.name } }
        end
      end

      def startup_faculty
        Faculty.left_joins(startups: :course).where(startups: { courses: { id: @course } }).where.not(exited: true)
      end

      def course_faculty_ids
        Faculty.left_joins(:courses).where(courses: { id: @course }).pluck(:id)
      end
    end
  end
end
