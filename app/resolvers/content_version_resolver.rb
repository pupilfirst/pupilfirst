class ContentVersionResolver < ApplicationResolver
  def collection(target_id)
    if authorized?(target_id)
      target = Target.find(target_id.to_i)

      if target.content_versions.present?
        target.content_versions.order('version_on DESC').distinct(:version_on).pluck(:version_on)
      else
        ContentVersion.none
      end
    else
      ContentVersion.none
    end
  end

  def authorized?(target_id)
    current_school_admin.present? || current_user&.course_authors&.where(course: Target.find(target_id.to_i).course).present?
  end
end
