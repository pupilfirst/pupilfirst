module Schools
  module FacultyModule
    class CourseIndexPresenter < ApplicationPresenter
      def initialize(view_context, course)
        super(view_context)

        @course = course
      end

      def props
        {
          course_coach_ids: course_coach_ids,
          school_coaches: school_faculty_details,
          course_id: @course.id,
          authenticity_token: view.form_authenticity_token
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
            image_url: faculty.user.avatar_url,
            teams: faculty_team_details(faculty)
          }
        end
      end

      def faculty_team_details(faculty)
        if faculty.startups.present?
          faculty.startups.joins(:course).where(courses: { id: @course }).map { |startup| { id: startup.id, name: startup.name } }
        else
          []
        end
      end

      def course_coach_ids
        Faculty.left_joins(:courses).where(courses: { id: @course }).pluck(:id)
      end
    end
  end
end
