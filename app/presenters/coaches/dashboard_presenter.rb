module Coaches
  class DashboardPresenter < ApplicationPresenter
    def react_props
      {
        coach: { name: current_coach.name, id: current_coach.id, imageUrl: current_coach.image_url },
        startups: startups,
        timelineEvents: FacultyModule::ReviewableTimelineEventsService.new(current_coach).timeline_events(view.current_school),
        authenticityToken: view.form_authenticity_token,
        emptyIconUrl: view.image_url('coaches/dashboard/empty_icon.svg'),
        notAcceptedIconUrl: view.image_url('coaches/dashboard/not-accepted-icon.svg'),
        verifiedIconUrl: view.image_url('coaches/dashboard/verified-icon.svg'),
        gradeLabels: grade_labels,
        passGrade: course.pass_grade
      }
    end

    private

    def current_coach
      @current_coach ||= view.current_coach
    end

    def startups
      @startups ||= begin
        direct_startup_ids = current_coach.startups.select(:id)
        course_startup_ids = Startup.joins(level: :course).where(courses: { id: current_coach.courses.select(:id) }).select(:id)

        Startup.where(id: direct_startup_ids).or(Startup.where(id: course_startup_ids)).map do |startup|
          {
            name: startup.product_name,
            id: startup.id,
            levelNumber: startup.level.number,
            levelName: startup.level.name,
            logoUrl: logo_url(startup)
          }
        end
      end
    end

    def course
      # TODO: Assuming a founder is assinged to one course for now. Rewrite to account for multiple course.
      current_coach.courses&.first || current_coach.startups.first.course
    end

    def grade_labels
      grade_labels = course.grade_labels
      grade_labels.keys.map { |grade| { grade: grade, label: grade_labels[grade] } }
    end

    def logo_url(startup)
      startup.logo_url || identicon_logo(startup)
    end

    def identicon_logo(startup)
      base64_logo = Startups::IdenticonLogoService.new(startup).base64_svg
      "data:image/svg+xml;base64,#{base64_logo}"
    end
  end
end
