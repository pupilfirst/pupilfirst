class ContentBlockResolver < ApplicationResolver
  def collection(target_id, version_id)
    if authorized?(target_id)
      if version_id.present?
        ContentBlock.where(id: TargetContentVersion.find(version_id).content_blocks).with_attached_file
      else
        ContentBlock.where(id: Target.find(target_id.to_i).latest_content_version&.content_blocks).with_attached_file
      end
    else
      School.none
    end
  end

  def authorized?(target_id)
    current_school_admin.present? || current_user&.course_authors&.where(course: Target.find(target_id.to_i).course).present?
  end
end
