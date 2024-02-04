module Layouts
  class AppRouterPresenter < ::ApplicationPresenter
    def initialize(view_context, course)
      @course = course
      super(view_context)
    end

    private

    def props
      {
        courses: course_details_array,
        current_user: user_details,
        school: school_details
      }
    end

    def school_details
      {
        name: school_name,
        logo_on_light_bg_url: logo_on_light_bg_url,
        logo_on_dark_bg_url: logo_on_dark_bg_url,
        icon_on_light_bg_url: icon_on_light_bg_url,
        icon_on_dark_bg_url: icon_on_dark_bg_url,
        cover_image_url: cover_image_url,
        links: nav_links
      }
    end

    def user_details
      user = {
        id: current_user.id,
        name: current_user.name,
        title: current_user.full_title,
        is_admin: current_school_admin.present?,
        can_edit_profile: show_user_edit?,
        has_notifications: notifications?,
        is_author: author?
      }
      if current_user.avatar.attached?
        user[:avatar_url] = view.rails_public_blob_url(
          current_user.avatar_variant(:thumb)
        )
      end

      user[:coach_id] = current_coach.id if current_coach.present?
      user
    end

    def courses
      if current_user.blank?
        current_school
          .courses.with_attached_thumbnail
          .live
          .where(public_preview: true)
          .order(sort_index: :asc)
      elsif current_school_admin.present?
        # All courses are available to admins.
        current_school.courses.with_attached_thumbnail.live.order(sort_index: :asc)
      else
        # current course if course has public preview.
        previewed_course = @course&.public_preview? ? [@course] : []

        (
          courses_with_author_access + courses_with_review_access +
            courses_with_student_profile + previewed_course
        ).uniq.sort_by { |course| course.name.downcase }
      end
    end

    def courses_with_student_profile
      @courses_with_student_profile ||=
        Course
          .joins(:students)
          .where(
            school: current_school,
            students: {
              id: current_user.students.select(:id)
            }
          ).order(sort_index: :asc)
          .to_a
    end

    def courses_with_review_access
      @courses_with_review_access ||=
        begin
          current_coach.present? ? current_coach.courses : Course.none
        end
    end

    def courses_with_review_access_ids
      @courses_with_review_access_ids ||= courses_with_review_access.pluck(:id)
    end

    def courses_with_author_access
      if current_user.course_authors.present?
        Course.joins(:course_authors).order(sort_index: :asc).where(
          course_authors: current_user.course_authors
        )
      else
        Course.none
      end
    end

    def author?
      current_user.course_authors.exists? && current_user.school_admin.blank?
    end

    def courses_with_author_access_ids
      @courses_with_author_access_ids ||= courses_with_author_access.pluck(:id)
    end

    def communities
      @communities ||=
        CommunityCourseConnection
          .where(id: courses.pluck(:id))
          .joins(:community)
          .map do |c|
            {
              id: c.community_id.to_s,
              name: c.community.name,
              course_id: c.course_id
            }
          end
    end

    def linked_communities(course)
      communities.select { |c| c[:course_id] == course.id }
    end

    def course_details_array
      courses.map do |course|
        {
          id: course.id,
          name: course.name,
          can_review: course.id.in?(courses_with_review_access_ids),
          is_author: course.id.in?(courses_with_author_access_ids),
          enable_leaderboard: course.enable_leaderboard?,
          description: course.description,
          exited: student_dropped_out(course.id),
          thumbnail_url: course.thumbnail_url,
          linked_communities: linked_communities(course),
          ended: course.ended?,
          is_student: student_profile?(course.id)
        }
      end
    end

    def student_profile?(course_id)
      courses_with_student_profile.detect { |c| c.id == course_id }.present?
    end

    def student_dropped_out(course_id)
      course_with_student =
        courses_with_student_profile.detect { |c| c.id == course_id }

      return false if course_with_student.blank?

      course_with_student[:dropped_out_at].present?
    end

    def show_user_edit?
      view.policy(current_user).edit?
    end

    def notifications?
      return false if current_user.blank?

      current_user.notifications.unread.any?
    end

    def course_authors
      @course_authors ||=
        current_user.course_authors.where(course: current_school.courses)
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
                { title: school_link.title, url: school_link.url }
              end

          # Both, with the user-based links at the front.
          admin_link + dashboard_link + coaches_link + custom_links
        end
    end

    def admin_link
      if current_school.present? && view.policy(current_school).show?
        [
          {
            title: I18n.t("presenters.layouts.app_router.admin_link.title"),
            url: view.school_path
          }
        ]
      elsif current_user.present? && course_authors.any?
        [
          {
            title: I18n.t("presenters.layouts.app_router.admin_link.title"),
            url: view.curriculum_school_course_path(course_authors.first.course)
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
            title: I18n.t("presenters.layouts.app_router.dashboard_link.title"),
            url: "/dashboard"
          }
        ]
      else
        []
      end
    end

    def coaches_link
      if current_school.users.joins(:faculty).exists?(faculty: { public: true })
        [
          {
            title: I18n.t("presenters.layouts.app_router.coaches_link.title"),
            url: "/coaches"
          }
        ]
      else
        []
      end
    end

    def school_name
      @school_name ||=
        current_school.present? ? current_school.name : "Pupilfirst"
    end

    def logo_on_light_bg_url
      if current_school.logo_on_light_bg.attached?
        view.rails_public_blob_url(current_school.logo_variant(:high))
      end
    end

    def logo_on_dark_bg_url
      if current_school.logo_on_dark_bg.attached?
        view.rails_public_blob_url(
          current_school.logo_variant(:high, background: :dark)
        )
      end
    end

    def cover_image_url
      if current_school.cover_image.attached?
        view.rails_public_blob_url(current_school.cover_image)
      end
    end

    def icon_on_light_bg_url
      if current_school.icon_on_light_bg.attached?
        view.rails_public_blob_url(current_school.icon_variant("thumb"))
      else
        "/favicon.png"
      end
    end

    def icon_on_dark_bg_url
      if current_school.icon_on_dark_bg.attached?
        view.rails_public_blob_url(
          current_school.icon_variant("thumb", background: :dark)
        )
      else
        "/favicon.png"
      end
    end
  end
end
