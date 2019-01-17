class CoachDashboardPresenter < ApplicationPresenter
  def initialize(view_context, course)
    @course = course
    super(view_context)
  end

  def react_props
    {
      coach: { name: current_coach.name, id: current_coach.id, imageUrl: current_coach.image_url },
      founders: founders,
      teams: teams,
      timelineEvents: timeline_events,
      moreToLoad: more_to_load?,
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
    Founder.where(startup_id: teams.map { |t| t[:id] }).map do |founder|
      {
        id: founder.id,
        name: founder.name,
        avatarUrl: avatar_url(founder),
        teamId: founder.startup_id
      }
    end
  end

  def teams
    @teams ||= current_coach.reviewable_startups(@course).map do |startup|
      {
        id: startup.id,
        name: startup.product_name
      }
    end
  end

  # Only load few latest pending timeline events initially.
  def timeline_events
    @timeline_events ||= TimelineEvent.pending_review.from_founders(founders.map { |f| f[:id] })
      .includes(:timeline_event_owners, :timeline_event_files, :startup_feedback)
      .includes(target: :level)
      .includes(:target_evaluation_criteria, :evaluation_criteria)
      .order(created_at: :DESC).limit(1).map { |timeline_event| timeline_event_fields(timeline_event) }
  end

  def timeline_event_fields(timeline_event)
    {
      id: timeline_event.id,
      title: title(timeline_event),
      description: timeline_event.description,
      eventOn: timeline_event.event_on,
      founderIds: founder_ids(timeline_event),
      links: timeline_event.links,
      files: files(timeline_event),
      image: timeline_event.image? ? timeline_event.image.url : nil,
      latestFeedback: timeline_event.startup_feedback&.last&.feedback,
      evaluation: evaluation(timeline_event),
      rubric: rubric(timeline_event)
    }
  end

  def title(timeline_event)
    timeline_event.target.level.short_name + ' | ' + timeline_event.target.title
  end

  def founder_ids(timeline_event)
    timeline_event.timeline_event_owners.map(&:founder_id)
  end

  def files(timeline_event)
    timeline_event.timeline_event_files.map { |file| { title: file.title, id: file.id } }
  end

  def evaluation(timeline_event)
    timeline_event.evaluation_criteria.map do |criterion|
      {
        criterionId: criterion.id,
        criterionName: criterion.name,
        grade: nil
      }
    end
  end

  def rubric(timeline_event)
    timeline_event.target.rubric_description
  end

  def more_to_load?
    TimelineEvent.pending_review.from_founders(founders.map { |f| f[:id] })
      .where.not(id: timeline_events.map { |te| te[:id] }).exists?
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
