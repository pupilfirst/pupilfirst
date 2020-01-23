class CreateEmbedContentBlockMutator < ApplicationQuery
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
      Targets::CreateContentVersionService.new(target, above_content_block).create(embed_block)
    end
  end

  private

  def embed_code
    @embed_code ||= ::Oembed::Resolver.new(url).embed_code
  rescue ::Oembed::Resolver::ProviderNotSupported
    nil
  end

  def create_embed_block
    ContentBlock.create!(
      block_type: ContentBlock::BLOCK_TYPE_EMBED,
      content: { url: url, embed_code: embed_code }
    )
  end
end
