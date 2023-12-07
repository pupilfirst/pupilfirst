class TargetDetailsResolver < ApplicationQuery
  property :target_id

  def target_details
    {
      title: target.title,
      target_group_id: target.target_group_id,
      visibility: target.visibility
    }
  end

  def authorized?
    return false if target&.course&.school != current_school

    current_school_admin.present? ||
      current_user&.course_authors&.where(course: target.course).present?
  end

  def target
    @target ||= Target.find_by(id: target_id)
  end
end
