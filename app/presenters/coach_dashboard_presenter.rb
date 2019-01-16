class CoachDashboardPresenter < ApplicationPresenter
  def initialize(view_context, course)
    @course = course
    super(view_context)
  end

  def react_props
    {
      coach: { name: current_coach.name, id: current_coach.id, imageUrl: current_coach.image_url },
      founders: founders,
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

  def founders
    Founder.where(startup: current_coach.reviewable_startups(@course)).map do |founder|
      {
        id: founder.id,
        name: founder.name,
        avatarUrl: avatar_url(founder)
      }
    end
  end

  def grade_labels
    grade_labels = @course.grade_labels
    grade_labels.keys.map { |grade| { grade: grade, label: grade_labels[grade] } }
  end

  def avatar_url(founder)
    founder.avatar_url || identicon_avatar(founder)
  end

  def identicon_avatar(founder)
    base64_logo = Founders::IdenticonLogoService.new(founder).base64_svg
    "data:image/svg+xml;base64,#{base64_logo}"
  end
end
