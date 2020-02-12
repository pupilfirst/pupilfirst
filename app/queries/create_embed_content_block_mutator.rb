class CreateEmbedContentBlockMutator < ApplicationQuery
  include AuthorizeAuthor
  include ContentBlockCreatable

  property :target_id, validates: { presence: true }
  property :url, validates: { presence: true, length: { maximum: 2048 } }
  property :above_content_block_id

  validate :embed_code_must_be_available

  def embed_code_must_be_available
    return if embed_code.present?

    errors[:base] << "Failed to embed the given URL. Please check if this is a supported website and try again."
  end

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
      content: { url: url, embed_code: embed_code },
      sort_index: sort_index
    )
  end
end
