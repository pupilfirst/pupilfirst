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

    # private

    def school_details
      { name: school_name, logo_url: logo_url, links: nav_links }
    end

    def user_details
      user = {
        name: current_user.name,
        title: current_user.full_title,
        is_admin: current_school_admin.present?,
        can_edit_profile: show_user_edit?,
        has_notifications: notifications?
      }
      if current_user.avatar.attached?
        user[:avatar_url] =
          view.rails_public_blob_url(current_user.avatar_variant(:thumb))
      end

      user[:coach_id] = current_coach.id if current_coach.present?
      user
    end

    def courses
      if current_user.blank?
        current_school.courses.live.where(public_preview: true)
      elsif current_school_admin.present?
        # All courses are available to admins.
        current_school.courses.live
      else
        # current course if course has public preview.
        previewed_course = @course.public_preview? ? [@course] : []

        (
          courses_with_author_access + courses_with_review_access +
            courses_with_student_profile + previewed_course
        ).uniq
      end
    end

    def courses_with_student_profile
      @courses_with_student_profile ||=
        Course
          .joins(:founders)
          .where(
            school: current_school,
            founders: {
              id: current_user.founders.select(:id)
            }
          )
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
        Course
          .joins(:course_authors)
          .where(course_authors: current_user.course_authors)
      else
        Course.none
      end
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
          access_ended: student_access_end(course.id),
          ended: course.ended?,
          is_student: student_profile?(course.id)
        }
      end
    end

    def student_profile?(course_id)
      courses_with_student_profile.detect { |c| c.id == course_id }.present?
    end

    def student_access_end(course_id)
      course_with_student =
        courses_with_student_profile.detect { |c| c.id == course_id }

      return false if course_with_student.blank?

      course_with_student[:access_ends_at].present? &&
        course_with_student[:access_ends_at].past?
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

    def nav_links
      @nav_links ||=
        begin
          # ...and the custom links.
          custom_links =
            SchoolLink
              .where(school: current_school, kind: SchoolLink::KIND_HEADER)
              .order(created_at: :DESC)
              .map do |school_link|
                { title: school_link.title, url: school_link.url }
              end

          # Both, with the user-based links at the front.
          admin_link + dashboard_link + coaches_link + custom_links
        end
    end

    def admin_link
      if current_school.present? && view.policy(current_school).show?
        [{ title: 'Admin', url: view.school_path }]
      elsif current_user.present? && course_authors.any?
        [
          {
            title: 'Admin',
            url: view.curriculum_school_course_path(course_authors.first.course)
          }
        ]
      else
        []
      end
    end

    def dashboard_link
      current_user.present? ? [{ title: 'Dashboard', url: '/dashboard' }] : []
    end

    def course_authors
      @course_authors ||=
        current_user.course_authors.where(course: current_school.courses)
    end

    def coaches_link
      if current_school.users.joins(:faculty).exists?(faculty: { public: true })
        [{ title: 'Coaches', url: '/coaches' }]
      else
        []
      end
    end

    def school_name
      @school_name ||=
        current_school.present? ? current_school.name : 'Pupilfirst'
    end

    def logo_url
      if current_school.logo_on_light_bg.attached?
        view.rails_public_blob_url(current_school.logo_variant(:high))
      end
    end
  end
end
