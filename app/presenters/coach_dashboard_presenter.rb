class CoachDashboardPresenter < ApplicationPresenter
  def initialize(view_context, course)
    @course = course
    super(view_context)
  end

  def react_props
    {
      coach: { name: current_coach.name, id: current_coach.id, imageUrl: current_coach.image_url },
      startups: startups,
      timelineEvents: FacultyModule::ReviewableTimelineEventsService.new(current_coach).timeline_events(@course),
      authenticityToken: view.form_authenticity_token,
      emptyIconUrl: view.image_url('coaches/dashboard/empty_icon.svg'),
      notAcceptedIconUrl: view.image_url('coaches/dashboard/not-accepted-icon.svg'),
      verifiedIconUrl: view.image_url('coaches/dashboard/verified-icon.svg'),
      gradeLabels: grade_labels,
      passGrade: @course.pass_grade
    }
  end

  private

  def current_coach
    @current_coach ||= view.current_coach
  end

  def startups
    current_coach.reviewable_startups(@course).includes(:level).map do |startup|
      {
        name: startup.product_name,
        id: startup.id,
        levelNumber: startup.level.number,
        levelName: startup.level.name,
        logoUrl: logo_url(startup)
      }
    end
  end

  def grade_labels
    grade_labels = @course.grade_labels
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
