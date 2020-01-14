class TargetDetailsResolver < ApplicationQuery
  property :target_id

  def target_details
    {
      title: target.title,
      role: target.role,
      evaluation_criteria: target.evaluation_criteria.pluck(:id),
      prerequisite_targets: target.prerequisite_targets.pluck(:id),
      completion_instructions: target.completion_instructions,
      link_to_complete: target.link_to_complete,
      visibility: target.visibility
    }
  end

  def authorized?
    current_school_admin.present? || current_user&.course_authors&.where(course: target.course).present?
  end

  def target
    @target = current_school.targets.where(id: target_id).first
  end
end
