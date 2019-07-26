module Schools
  module Courses
    class InactiveStudentsPresenter < ApplicationPresenter
      def initialize(view_context, teams, course)
        super(view_context)
        @teams = teams
        @course = course
      end

      def props
        {
          teams: team_details(@teams),
          course_id: @course.id,
          students: students,
          student_tags: founder_tags,
          current_page: @teams.current_page,
          is_last_page: @teams.last_page?,
          authenticity_token: view.form_authenticity_token
        }
      end

      def team_details(teams)
        teams.map do |team|
          team.attributes.slice('id', 'name')
        end
      end

      def students
        @students ||=
          founders.includes(user: { avatar_attachment: :blob }, taggings: :tag).map do |student|
            {
              id: student.id,
              email: student.email,
              tags: student.taggings.map { |tagging| tagging.tag.name } & founder_tags,
              team_id: student.startup_id,
              name: student.user.name,
              avatar_url: student.user.image_or_avatar_url
            }
          end
      end

      private

      def founder_tags
        @founder_tags ||= current_school.founder_tag_list
      end

      def founders
        @founders ||= Founder.where(startup: @teams)
      end
    end
  end
end
