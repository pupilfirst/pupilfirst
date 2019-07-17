module Schools
  module Founders
    class IndexPresenter < ApplicationPresenter
      def initialize(view_context, course)
        super(view_context)

        @course = course
      end

      def react_props
        {
          teams: teams,
          courseId: @course.id,
          students: students,
          courseCoachIds: @course.faculty.pluck(:id),
          schoolCoaches: coach_details,
          levels: levels,
          studentTags: founder_tags,
          authenticityToken: view.form_authenticity_token
        }
      end

      def teams
        startups.includes(:level, :faculty_startup_enrollments).order(:id).map do |team|
          {
            id: team.id,
            name: team.name,
            coachIds: team.faculty_startup_enrollments.pluck(:faculty_id),
            levelNumber: team.level.number
          }
        end
      end

      def students
        @students ||=
          founders.includes(taggings: :tag, user: { avatar_attachment: :blob }).map do |student|
            {
              id: student.id,
              name: student.user.name,
              avatarUrl: student.user.image_or_avatar_url,
              email: student.user.email,
              teamId: student.startup_id,
              tags: student.taggings.map { |tagging| tagging.tag.name } & founder_tags,
              exited: student.exited,
              excludedFromLeaderboard: student.excluded_from_leaderboard
            }
          end
      end

      private

      def coach_details
        @coach_details ||=
          current_school.faculty.where.not(exited: true).includes(user: { avatar_attachment: :blob }).map do |coach|
            {
              id: coach.id,
              name: coach.user.name,
              avatarUrl: coach.user.image_or_avatar_url
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
