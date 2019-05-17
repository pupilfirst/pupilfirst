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
          user_profiles: user_profiles,
          student_tags: founder_tags,
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
          founders.includes(:user, taggings: :tag).map do |student|
            student.attributes.slice('id', 'email', 'team_id', 'tags', 'user_id')
            {
              id: student.id,
              email: student.email,
              tags: student.taggings.map { |tagging| tagging.tag.name } & founder_tags,
              team_id: student.startup_id,
              user_id: student.user_id
            }
          end
      end

      def user_profiles
        UserProfile.with_attached_avatar.where(user_id: students.pluck(:user_id), school: current_school).uniq.map do |profile|
          profile.attributes.slice('user_id', 'name').merge(avatar_url: avatar_url(profile))
        end
      end

      private

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

      def founders
        @founders ||= Founder.where(startup: @teams).not_exited
      end
    end
  end
end
