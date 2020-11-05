module Schools
  module Courses
    class StudentsPresenter < ApplicationPresenter
      def initialize(view_context, course)
        super(view_context)

        @course = course
      end

      def props
        {
          course_id: @course.id,
          course_coach_ids: @course.faculty.pluck(:id),
          school_coaches: school_coaches,
          levels: levels,
          student_tags: student_tags,
          certificates: certificates,
          current_user_name: current_user.name,
        }
      end

      private

      def school_coaches
        current_school.faculty.where.not(exited: true).includes(:user).map do |coach|
          {
            id: coach.id,
            name: coach.name
          }
        end
      end

      def levels
        @levels ||= @course.levels.map do |level|
          {
            id: level.id,
            name: level.name,
            number: level.number
          }
        end
      end

      def student_tags
        @student_tags ||= current_school.founder_tag_list
      end

      def certificates
        @course.certificates.map do |certificate|
          {
            id: certificate.id,
            name: certificate.name,
            active: certificate.active,
          }
        end
      end
    end
  end
end
