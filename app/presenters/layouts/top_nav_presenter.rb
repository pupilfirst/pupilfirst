module Layouts
  class TopNavPresenter < ApplicationPresenter
    def visible_links
      if nav_links.length > 4
        nav_links[0..2]
      else
        nav_links
      end
    end

    def more_links
      @more_links ||= begin
        if nav_links.length > 4
          {
            title: 'More',
            id: 'navbar-more-dropdown',
            options: nav_links[-(nav_links.length - 3)..-1]
          }
        end
      end
    end

    def selectable_student_profiles
      @selectable_student_profiles ||= begin
        if view.current_school.blank? || view.current_founder.blank?
          Founder.none
        else
          view.current_user.founders
            .not_exited
            .where.not(id: view.current_founder.id)
            .joins(:school).where(schools: { id: view.current_school })
        end
      end
    end

    private

    def nav_links
      @nav_links ||= begin
        # User-based links...
        links = [admin_link, review_link, dashboard_link] - [nil]

        # ...and the custom links.
        custom_links = SchoolLink.where(school: view.current_school, kind: SchoolLink::KIND_HEADER).map do |school_link|
          { title: school_link.title, url: school_link.url }
        end

        # Both, with the user-based links at the front.
        links + custom_links
      end
    end

    def admin_link
      { title: 'Admin', url: '/school' } if view.policy(view.current_school).show?
    end

    def review_link
      coach = view.current_coach
      courses = coach&.courses_with_dashboard

      return if coach.blank? || courses.blank?

      title = -'Review Submissions'

      if courses.count == 1
        { title: title, url: view.course_coach_dashboard_path(courses.first) }
      else
        {
          title: title,
          id: 'navbar-review-dropdown',
          options: courses.map { |c| { title: c.name, url: view.course_coach_dashboard_path(c) } }
        }
      end
    end

    def dashboard_link
      return if view.current_founder.blank? || view.current_founder.exited? || view.current_founder.startup.blank?

      { title: 'Student Dashboard', url: view.student_dashboard_path }
    end
  end
end
