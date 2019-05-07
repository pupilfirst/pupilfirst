module Layouts
  class TopNavTailwindPresenter < ::ApplicationPresenter
    def json_props
      {
        logo: logo_url,
        schoolName: school_name,
        links: nav_links
      }.to_json
    end

    private

    def school_name
      @school_name ||= current_school.present? ? current_school.name : 'PupilFirst'
    end

    def logo_url
      if current_school.blank?
        view.image_url('mailer/pupilfirst-logo.png')
      else
        view.url_for(current_school.logo_variant(:mid))
      end
    end

    def selectable_student_profiles
      @selectable_student_profiles ||= begin
        if current_school.blank? || current_founder.blank?
          Founder.none
        else
          current_user.founders
            .not_exited
            .joins(:school).where(schools: { id: current_school })
        end
      end
    end

    def nav_links
      @nav_links ||= begin
        # User-based links...
        links = [admin_link, review_link, dashboard_link, leaderboard_link] - [nil]

        # ...and the custom links.
        custom_links = SchoolLink.where(school: current_school, kind: SchoolLink::KIND_HEADER).order(created_at: :DESC).map do |school_link|
          { title: school_link.title, url: school_link.url, methord: "get" }
        end

        # Both, with the user-based links at the front.
        links + custom_links
      end
    end

    def admin_link
      { title: 'Admin', url: '/school', methord: :get } if current_school.present? && view.policy(current_school).show?
    end

    def review_link
      courses = current_coach&.courses_with_dashboard

      return if current_coach.blank? || courses.blank?

      title = -'Review Submissions'

      if courses.count == 1
        { title: title, url: view.course_coach_dashboard_path(courses.first, methord: :get) }
      else
        {
          title: title,
          options: courses.map { |c| { title: c.name, url: view.course_coach_dashboard_path(c), methord: :get } }
        }
      end
    end

    def dashboard_link
      return if current_founder.blank? || current_founder.exited?

      if selectable_student_profiles.load.count > 1
        {
          title: 'Student Dashboard',
          options: selectable_student_profiles.map do |sp|
            { title: "#{sp.course.name} Course", url: view.select_founder_path(sp), method: :post }
          end
        }
      else
        { title: 'Student Dashboard', url: view.student_dashboard_path, method: :post }
      end
    end

    def leaderboard_link
      return if current_founder.blank? || current_founder.exited?

      lts = LeaderboardTimeService.new
      course = current_founder.course

      course_entries_last_week = LeaderboardEntry.joins(:course).where(
        courses: { id: course },
        period_from: lts.week_start,
        period_to: lts.week_end
      )

      if course_entries_last_week.exists?
        { title: 'Leaderboard', url: view.leaderboard_course_path(course), methord: :get }
      end
    end
  end
end
