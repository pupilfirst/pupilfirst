class SortContentBlocksMutator < ApplicationQuery
  property :content_block_ids, validates: { presence: true }

  def sort
    ::ContentBlocks::SortService.new(content_block_ids).execute
  end

  def target_versions
    target.content_versions.order('version_on DESC').distinct(:version_on).pluck(:version_on)
  end

  private

  def target
    ContentVersion.where(content_block_id: content_block_ids).first.target
  end

  def authorized?
    current_school_admin.present? || current_user.course_authors.where(course: target.level.course).exists?
  end
end
