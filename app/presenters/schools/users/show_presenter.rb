module Schools
  module Users
    class ShowPresenter < ApplicationPresenter
      attr_reader :user
      delegate :avatar_url, to: :user

      def initialize(view_context, user)
        @user = user
        super(view_context)
      end

      def courses_taken
        @courses_taken ||=
          Course
            .joins(cohorts: { students: :user })
            .where(users: { id: user.id })
            .order(name: :asc)
            .distinct
      end

      def courses_coached
        @courses_coached ||=
          Course
            .joins(cohorts: { faculty: :user })
            .where(users: { id: user.id })
            .order(name: :asc)
            .distinct
      end

      def courses_authored
        @courses_authored ||=
          Course
            .joins(course_authors: :user)
            .where(users: { id: user.id })
            .order(name: :asc)
      end

      def affiliation
        @affiliation ||= user.affiliation || user.organisation&.name
      end

      def current_standing
        @current_standing ||=
          user
            .user_standings
            .includes(:standing)
            .live
            .order(created_at: :desc)
            .first
            &.standing || current_school.default_standing
      end

      def role_labels
        @role_labels ||=
          begin
            labels = []
            labels << t("admin") if user.school_admin.present?
            labels << t("student") if courses_taken.present?
            labels << t("coach") if courses_coached.present?
            labels << t("author") if courses_authored.present?

            labels.join(" • ")
          end
      end

      def user_tags
        user.tags.map { |t| t.name }
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

      def t(key)
        I18n.t("presenters.schools.users.show.#{key}")
      end
    end
  end
end
