module Layouts
  class StudentTopNavPresenter < ::ApplicationPresenter
    def props
      {
        school_name: school_name,
        logo_on_light_bg_url: logo_url(:light),
        logo_on_dark_bg_url: logo_url(:dark),
        links: nav_links,
        authenticity_token: view.form_authenticity_token,
        is_logged_in: current_user.present?,
        current_user: user_details,
        has_notifications: notifications?
      }
    end

    def school_name
      @school_name ||=
        current_school.present? ? current_school.name : "Pupilfirst"
    end

    def logo_url(background)
      if current_school.blank?
        view.image_url("mailer/pupilfirst-logo.png")
      elsif background == :light && current_school.logo_on_light_bg.attached?
        view.rails_public_blob_url(current_school.logo_variant(:high))
      elsif background == :dark && current_school.logo_on_dark_bg.attached?
        view.rails_public_blob_url(
          current_school.logo_variant(:high, background: :background)
        )
      end
    end

    private

    def notifications?
      return false if current_user.blank?

      current_user.notifications.unread.any?
    end

    def nav_links
      @nav_links ||=
        begin
          # ...and the custom links.
          custom_links =
            SchoolLink
              .where(school: current_school, kind: SchoolLink::KIND_HEADER)
              .order(:sort_index)
              .map do |school_link|
                { title: school_link.title, url: school_link.url, local: false }
              end

          # Both, with the user-based links at the front.
          admin_link + dashboard_link + orgs_link + coaches_link + custom_links
        end
    end

    def admin_link
      if current_school.present? && view.policy(current_school).show?
        [
          {
            title:
              I18n.t("presenters.layouts.students_top_nav.admin_link.title"),
            url: view.school_path,
            local: true
          }
        ]
      elsif current_user.present? && course_authors.any?
        [
          {
            title:
              I18n.t("presenters.layouts.students_top_nav.admin_link.title"),
            url:
              view.curriculum_school_course_path(course_authors.first.course),
            local: true
          }
        ]
      else
        []
      end
    end

    def dashboard_link
      if current_user.present?
        [
          {
            title:
              I18n.t(
                "presenters.layouts.students_top_nav.dashboard_link.title"
              ),
            url: "/dashboard",
            local: true
          }
        ]
      else
        []
      end
    end

    def orgs_link
      if current_user.present? && view.policy_scope(Organisation).exists?
        [
          {
            title:
              I18n.t(
                "presenters.layouts.students_top_nav.organisations_link.title"
              ),
            url: view.organisations_path,
            local: true
          }
        ]
      else
        []
      end
    end

    def course_authors
      @course_authors ||=
        current_user.course_authors.where(course: current_school.courses)
    end

    def user_details
      return if current_user.blank?
      {
        id: current_user.id,
        name: current_user.name,
        full_title: current_user.full_title,
        avatar_url: current_user.avatar_url(variant: :thumb)
      }
    end

    def coaches_link
      if current_school.users.joins(:faculty).exists?(faculty: { public: true })
        [
          {
            title:
              I18n.t("presenters.layouts.students_top_nav.coaches_link.title"),
            url: "/coaches",
            local: true
          }
        ]
      else
        []
      end
    end
  end
end
