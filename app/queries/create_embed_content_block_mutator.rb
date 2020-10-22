class CreateEmbedContentBlockMutator < ApplicationQuery
  include AuthorizeAuthor
  include ContentBlockCreatable

  property :target_id, validates: { presence: true }
  property :url, validates: { presence: true, url: true }
  property :above_content_block_id
  property :request_source, validates: { presence: true }

  def create_embed_content_block
    ContentBlock.transaction do
      embed_block = create_embed_block
      shift_content_blocks_below(embed_block)
      target_version.touch # rubocop:disable Rails/SkipsModelValidations
      json_attributes(embed_block)
    end
  end

  private

  def embed_code
    @embed_code ||= ::Oembed::Resolver.new(url).embed_code
  rescue ::Oembed::Resolver::ProviderNotSupported
    nil
  end

  def create_embed_block
    target_version.content_blocks.create!(
      block_type: ContentBlock::BLOCK_TYPE_EMBED,
      content: { url: url, request_source: request_source, embed_code: embed_code, last_resolved_at: Time.zone.now },
      sort_index: sort_index
    )
  end
end
