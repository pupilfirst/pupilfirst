class CreateMarkdownContentBlockMutator < ApplicationQuery
  property :target_id, validates: { presence: true }
  property :above_content_block_id

  def create_markdown_content_block
    ContentBlock.transaction do
      markdown_block = create_markdown_block
      Targets::CreateContentVersionService.new(target, above_content_block).create(markdown_block)
    end
  end

  private

  def create_markdown_block
    ContentBlock.create!(
      block_type: ContentBlock::BLOCK_TYPE_MARKDOWN,
      content: { markdown: "" }
    )
  end

  def authorized?
    target.present? && (current_school_admin.present? || current_user.course_authors.where(course: target.level.course).exists?)
  end

  def target
    @target ||= Target.find_by(id: target_id)
  end

  def latest_version_date
    @latest_version_date ||= target.latest_content_version_date
  end

  def above_content_block
    @above_content_block ||= begin
      target.content_blocks.find_by(id: above_content_block_id) if above_content_block_id.present?
    end
  end
end
