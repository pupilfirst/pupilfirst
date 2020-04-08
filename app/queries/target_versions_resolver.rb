class TargetVersionsResolver < ApplicationQuery
  property :target_id

  def target_versions
    target.target_versions.order('created_at DESC')
  end

  def target
    @target ||= Target.find(target_id.to_i)
  end

  def authorized?
    current_school_admin.present? || current_user&.course_authors&.where(course: target.course).present?
  end
end
