class UpdateCommunityWidgetContentBlockMutator < ApplicationQuery
  include AuthorizeAuthor
  include ContentBlockEditable

  property :id, validates: { presence: true }
  property :kind, validates: { presence: true }
  property :slug, validates: { presence: true }

  def update_community_widget_content_block
    content_block.update!(content: { kind: kind.strip, slug: slug.strip })
    target_version.touch # rubocop:disable Rails/SkipsModelValidations
    json_attributes
  end
end
