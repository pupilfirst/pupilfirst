class ContentBlockResolver < ApplicationResolver
  def collection(target_id, version_id)
    if authorized?(target_id)
      target = Target.find(target_id.to_i)
      if version_id.present?
        ContentBlock.where(id: target.target_content_versions.find(version_id)&.content_blocks).with_attached_file
      else
        ContentBlock.where(id: target.latest_content_version&.content_blocks).with_attached_file
      end
    else
      School.none
    end
  end

  def authorized?(target_id)
    current_school_admin.present? || current_user&.course_authors&.where(course: Target.find(target_id.to_i).course).present?
  end
end
