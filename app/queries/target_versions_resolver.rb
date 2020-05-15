class TargetVersionsResolver < ApplicationQuery
  property :target_id

  def target_versions
    target.target_versions.order('created_at DESC')
  end

  def target
    @target ||= Target.find_by(id: target_id.to_i)
  end

  def authorized?
    return false if target&.course&.school != current_school

    return true if current_school_admin.present?

    current_user.present? && current_user.course_authors.where(course: target.course).present?
  end
end
