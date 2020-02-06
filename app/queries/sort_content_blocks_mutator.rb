class SortContentBlocksMutator < ApplicationQuery
  property :content_block_ids, validates: { presence: true }

  def sort
    ContentBlock.transaction do
      content_block_ids.each_with_index do |id, index|
        content_blocks.where(id: id).update!(sort_index: index + 1)
      end

      target_version.touch # rubocop:disable Rails/SkipsModelValidations
    end
  end

  private

  def target
    @target ||= ContentBlock.where(id: content_block_ids.first).target
  end

  def content_blocks
    @content_blocks ||= target.current_content_blocks
  end

  def authorized?
    current_school_admin.present? || current_user.course_authors.where(course: target.level.course).exists?
  end
end
