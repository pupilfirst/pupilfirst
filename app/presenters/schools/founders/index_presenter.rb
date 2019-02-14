module Schools
  module Founders
    class IndexPresenter < ApplicationPresenter
      def initialize(view_context, course)
        super(view_context)

        @course = course
      end

      def react_props
        { teams: teams }
      end

      def teams
        @course.startups.includes(:level, :founders, :faculty).order(:id).map do |team|
          {
            name: team.product_name,
            students: student_details(team.founders)
          }
        end
      end

      private

      def student_details(students)
        students.map do |student|
          {
            id: student.id,
            name: student.name,
            avatarUrl: student.avatar_url || student.initials_avatar
          }
        end
      end

      def team?(startup)
        @team ||= Hash.new do |hash, s|
          hash[s] = s.founders.length > 1
        end

        @team[startup]
      end
    end
  end
end
