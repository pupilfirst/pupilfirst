class SubmissionDetailsResolver < ApplicationResolver
  attr_accessor :submission_id

  def submission_details
    submissions = TimelineEvent.where(target_id: submission.target_id)
      .includes(:timeline_event_owners)
      .where(timeline_event_owners: { founder_id: submission.founders.pluck(:id) }).includes(:startup_feedback, :timeline_event_grades, :evaluator).order("timeline_events.created_at").reverse

    {
      submissions: submissions,
      target_id: target.id,
      target_title: target.title,
      user_names: user_names,
      level_number: level.number,
      level_id: level.id,
      evaluation_criteria: target.evaluation_criteria,
      review_checklist: review_checklist
    }
  end

  def submission
    @submission ||= TimelineEvent.find_by(id: submission_id)
  end

  def target
    @target ||= submission.target
  end

  def level
    @level ||= target.level
  end

  def user_names
    submission.founders.map do |founder|
      founder.user.name
    end.join(', ')
  end

  delegate :review_checklist, to: :target

  def authorized?
    return false if submission.blank?

    return false if current_user.faculty.blank?

    current_user.faculty.reviewable_courses.where(id: target.course).exists?
  end
end
