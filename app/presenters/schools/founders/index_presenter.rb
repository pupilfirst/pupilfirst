module Schools
  module Founders
    class IndexPresenter < ApplicationPresenter
      def initialize(view_context, course)
        super(view_context)

        @course = course
      end

      def react_props
        { teams: teams, authenticityToken: view.form_authenticity_token }
      end

      def teams
        @course.startups.includes(:level, :faculty, founders: :user).order(:id).map do |team|
          {
            id: team.id,
            name: team.product_name,
            students: student_details(team.founders),
            coaches: (coach_details(team.faculty) + course_coaches).uniq,
            levelNumber: team.level.number
          }
        end
      end

      private

      def student_details(students)
        students.map do |student|
          {
            id: student.id,
            name: student.name,
            avatarUrl: student.avatar_url || student.initials_avatar,
            teamId: student.startup.id,
            teamName: student.startup.product_name,
            email: student.user.email
          }
        end
      end

      def coach_details(coaches)
        coaches.map do |coach|
          {
            avatarUrl: coach.image_or_avatar_url
          }
        end
      end

      def course_coaches
        @course_coaches ||= coach_details(@course.faculty)
      end
    end
  end
end
