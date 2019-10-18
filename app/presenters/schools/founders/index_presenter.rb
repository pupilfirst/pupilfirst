module Schools
  module Founders
    class IndexPresenter < ApplicationPresenter
      def initialize(view_context, course)
        super(view_context)

        @course = course
      end

      def props
        {
          teams: teams,
          course_id: @course.id,
          students: students,
          course_coach_ids: @course.faculty.pluck(:id),
          school_coaches: coach_details,
          levels: levels,
          student_tags: founder_tags,
          authenticity_token: view.form_authenticity_token
        }
      end

      def teams
        startups.includes(:level, :faculty_startup_enrollments).order(:id).map do |team|
          {
            id: team.id,
            name: team.name,
            coach_ids: team.faculty_startup_enrollments.pluck(:faculty_id),
            level_number: team.level.number
          }
        end
      end

      def students
        @students ||=
          founders.includes(taggings: :tag, user: { avatar_attachment: :blob }).map do |student|
            student_props = {
              id: student.id,
              name: student.user.name,
              email: student.user.email,
              team_id: student.startup_id,
              tags: student.taggings.map { |tagging| tagging.tag.name } & founder_tags,
              exited: student.exited,
              excluded_from_leaderboard: student.excluded_from_leaderboard,
              title: student.user.title,
              affiliation: student.user.affiliation
            }

            if student.user.avatar.attached?
              student_props[:avatar_url] = view.url_for(student.user.avatar_variant(:thumb))
            end

            student_props
          end
      end

      private

      def coach_details
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
            name: level.name,
            number: level.number
          }
        end
      end

      def founder_tags
        @founder_tags ||= current_school.founder_tag_list
      end

      def startups
        @startups ||= @course.startups.active
      end

      def founders
        @founders ||= Founder.where(startup: startups)
      end
    end
  end
end
