class CreateCommunityWidgetContentBlockMutator < ApplicationQuery
  include AuthorizeAuthor
  include ContentBlockCreatable

  property :target_id, validates: { presence: true }
  property :above_content_block_id
  property :kind, validates: { presence: true }
  property :slug, validates: { presence: true }

  def create_community_widget_content_block
    ContentBlock.transaction do
      block = create_community_widget_block
      shift_content_blocks_below(block)
      target_version.touch # rubocop:disable Rails/SkipsModelValidations
      json_attributes(block)
    end
  end

  private

  def create_community_widget_block
    target_version.content_blocks.create!(
      block_type: ContentBlock::BLOCK_TYPE_COMMUNITY_WIDGET,
      content: { kind: kind, slug: slug, last_resolved_at: Time.zone.now },
      sort_index: sort_index
    )
  end
end
