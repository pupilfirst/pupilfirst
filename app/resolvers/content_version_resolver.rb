class ContentVersionResolver < ApplicationResolver
  def collection(target_id)
    if authorized?(target_id)
      target = Target.find(target_id.to_i)

      if target.content_versions.present?
        target.content_versions.distinct(:version_on).pluck(:version_on)
      end
    else
      School.none
    end
  end

  def authorized?(target_id)
    current_school_admin.present? || current_user&.course_authors&.where(course: Target.find(target_id.to_i).course).present?
  end
end
