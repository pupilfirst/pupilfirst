module Schools
  module Users
    class ShowPresenter < ApplicationPresenter
      attr_reader :user

      def initialize(view_context, user)
        @user = user
        super(view_context)
      end

      def avatar_url
        user.avatar_url || user.initials_avatar
      end

      def courses_taken
        @courses_taken ||=
          begin
            Course
              .joins(cohorts: { students: :user })
              .where(users: { id: user.id })
              .order(name: :asc)
              .distinct
          end
      end

      def courses_coached
        @courses_coached ||=
          begin
            Course
              .joins(cohorts: { faculty: :user })
              .where(users: { id: user.id })
              .order(name: :asc)
              .distinct
          end
      end

      def courses_authored
        @courses_authored ||=
          begin
            Course
              .joins(course_authors: :user)
              .where(users: { id: user.id })
              .order(name: :asc)
          end
      end

      def organisation_names
        @organisation_names ||= user.organisation&.name
      end

      def current_standing
        @current_standing ||=
          begin
            user
              .user_standings
              .includes(:standing)
              .live
              .order(created_at: :desc)
              .first
              &.standing || current_school.default_standing
          end
      end

      def type_tags
        @type_tags ||=
          begin
            tags = []
            tags << "Admin" if user.school_admin.present?
            tags << "Student" if courses_taken.present?
            tags << "Coach" if courses_coached.present?
            tags << "Author" if courses_authored.present?

            tags.join(" • ")
          end
      end

      def tags
        user.tags.map { |t| t.name.titleize }
      end

      def user_course_cohort(course)
        @user_course_cohorts ||= user.cohorts

        @user_course_cohorts.find { |c| c.course_id == course.id }
      end

      def course_student(course)
        @course_students ||= user.students

        @course_students.find do |cs|
          cs.cohort_id == user_course_cohort(course).id
        end
      end

      def discord_role_names
        @discord_role_names ||=
          begin
            cohort_role_ids =
              @user.cohorts.flat_map { |cr| cr.discord_role_ids }

            additional_discord_role_ids = user.discord_roles.pluck(:discord_id)

            current_school
              .discord_roles
              .where(discord_id: cohort_role_ids + additional_discord_role_ids)
              .order(position: :asc)
              .pluck(:name)
          end
      end
    end
  end
end
