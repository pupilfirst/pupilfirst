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
          userProfiles: user_profiles,
          courseCoachIds: @course.faculty.pluck(:id),
          schoolCoaches: coach_details,
          levels: levels,
          studentTags: founder_tags,
          authenticityToken: view.form_authenticity_token
        }
      end

      def teams
        @course.startups.includes(:level, :faculty_startup_enrollments).order(:id).map do |team|
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
          @course.founders.includes(:user, taggings: :tag).map do |student|
            {
              id: student.id,
              email: student.user.email,
              teamId: student.startup_id,
              tags: student.taggings.map { |tagging| tagging.tag.name } & founder_tags,
              exited: student.exited,
              excludedFromLeaderboard: student.excluded_from_leaderboard,
              userId: student.user_id
            }
          end
      end

      def user_profiles
        UserProfile.with_attached_avatar.where(user_id: (students.pluck(:userId) + coach_details.pluck(:userId)), school: current_school).uniq.map do |profile|
          {
            userId: profile.user_id,
            name: profile.name,
            avatarUrl: avatar_url(profile)
          }
        end
      end

      private

      def coach_details
        @coach_details ||=
          current_school.faculty.where.not(exited: true).map do |coach|
            {
              id: coach.id,
              userId: coach.user_id
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

      def avatar_url(user_profile)
        if user_profile.avatar.attached?
          view.url_for(user_profile.avatar_variant(:mid))
        else
          user_profile.initials_avatar
        end
      end

      def founder_tags
        @founder_tags ||= current_school.founder_tag_list
      end
    end
  end
end
