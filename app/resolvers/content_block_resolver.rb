class ContentBlockResolver < ApplicationResolver
  def collection(target_id, version_id)
    if current_school_admin.present?
      if version_id.present?
        ContentBlock.where(id: TargetContentVersion.find(version_id).content_blocks)
      else
        ContentBlock.where(id: Target.find(target_id.to_i).latest_content_version.content_blocks)
      end
    else
      School.none
    end
  end
end
