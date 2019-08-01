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
      courseId: @course.id,
      coachName: current_user.name
    }
  end

  private

  def founder_details
    @founder_details ||= founders.includes(user: { avatar_attachment: :blob }).map do |founder|
      user = founder.user
      {
        id: founder.id,
        name: user.name,
        avatarUrl: user.image_or_avatar_url,
        teamId: founder.startup_id
      }
    end
  end

  def team_details
    @team_details ||= teams.map do |startup|
      {
        id: startup.id,
        name: startup.name
      }
    end
  end

  def founders
    @founders ||= Founder.joins(:user, :startup).where(startups: { id: teams })
  end

  def teams
    @teams ||= current_coach.reviewable_startups(@course)
  end

  def timeline_events_service
    @timeline_events_service ||= CoachDashboard::TimelineEventsDataService.new(current_coach, @course, limit: 100)
  end

  def evaluated_submissions_exist?
    TimelineEvent.joins(:founders).where(founders: { id: founders })
      .where(target: @course.targets)
      .where.not(evaluator: nil).exists?
  end

  def grade_labels
    grade_labels = @course.grade_labels
    grade_labels.keys.map { |grade| { grade: grade.to_i, label: grade_labels[grade] } }
  end
end
