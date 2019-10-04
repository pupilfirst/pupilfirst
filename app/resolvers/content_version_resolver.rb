class ContentVersionResolver < ApplicationResolver
  attr_accessor :target_id

  def versions
    if target.content_versions.present?
      target.content_versions.order('version_on DESC').distinct(:version_on).pluck(:version_on)
    else
      ContentVersion.none
    end
  end

  def target
    @target ||= Target.find(target_id.to_i)
  end

  def authorized?
    current_school_admin.present? || current_user&.course_authors&.where(course: target.course).present?
  end
end
