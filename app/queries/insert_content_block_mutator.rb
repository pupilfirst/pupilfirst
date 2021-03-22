class InsertContentBlockMutator < ApplicationQuery
  include AuthorizeAuthor
  include ContentBlockCreatable

  property :target_id, validates: { presence: true }
  property :block_type, validates: { presence: true }
  property :above_content_block_id

  def insert_content_block
    ContentBlock.transaction do
      block = create_content_block
      shift_content_blocks_below(block)
      target_version.touch # rubocop:disable Rails/SkipsModelValidations
      json_attributes(block)
    end
  end

  private

  def create_content_block
    target_version.content_blocks.create!(
      block_type: block_type,
      content: { last_resolved_at: Time.zone.now },
      sort_index: sort_index
    )
  end
end
