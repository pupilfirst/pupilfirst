class ContentVersionResolver < ApplicationQuery
  property :target_id

  def versions
    if target.target_versions.present?
      target.target_versions.order('version_at DESC').distinct(:version_at).pluck(:version_at)
    else
      TargetVersion.none
    end
  end

  def target
    @target ||= Target.find(target_id.to_i)
  end

  def authorized?
    current_school_admin.present? || current_user&.course_authors&.where(course: target.course).present?
  end
end
