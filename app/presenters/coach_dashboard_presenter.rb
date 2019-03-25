class CoachDashboardPresenter < ApplicationPresenter
  def initialize(view_context, course)
    @course = course
    super(view_context)
  end

  def react_props
    {
      founders: founder_details,
      teams: team_details,
      timelineEvents: timeline_events_service.timeline_events,
      morePendingSubmissionsAfter: timeline_events_service.earliest_submission_date,
      moreReviewedSubmissionsAfter: evaluated_submissions_exist? ? Time.zone.now.strftime("%b %d, %Y") : nil,
      authenticityToken: view.form_authenticity_token,
      emptyIconUrl: view.image_url('coaches/dashboard/empty_icon.svg'),
      notAcceptedIconUrl: view.image_url('coaches/dashboard/not-accepted-icon.svg'),
      verifiedIconUrl: view.image_url('coaches/dashboard/verified-icon.svg'),
      gradeLabels: grade_labels,
      passGrade: @course.pass_grade,
      courseId: @course.id
    }
  end

  private

  def founder_details
    @founder_details ||= founders.map do |founder|
      {
        id: founder.id,
        name: founder.name,
        avatarUrl: avatar_url(founder),
        teamId: founder.startup_id
      }
    end
  end

  def team_details
    @team_details ||= teams.map do |startup|
      {
        id: startup.id,
        name: startup.product_name
      }
    end
  end

  def founders
    @founders ||= Founder.joins(:startup).where(startups: { id: teams })
  end

  def teams
    @teams ||= current_coach.reviewable_startups(@course)
  end

  def timeline_events_service
    @timeline_events_service ||= CoachDashboard::TimelineEventsDataService.new(current_coach, @course)
  end

  def evaluated_submissions_exist?
    TimelineEvent.joins(:founders).where(founders: { id: founders })
      .where(target: @course.targets)
      .where.not(evaluator: nil).exists?
  end

  def grade_labels
    grade_labels = @course.grade_labels
    grade_labels.keys.map { |grade| { grade: grade, label: grade_labels[grade] } }
  end

  def avatar_url(founder)
    if founder.avatar.attached?
      view.url_for(founder.avatar_variant(:mid))
    else
      founder.initials_avatar
    end
  end
end
