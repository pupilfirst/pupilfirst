class ResolveEmbedCodeMutator < ApplicationQuery
  include AuthorizeAuthor
  property :content_block_id, validates: { presence: true }

  validate :must_be_embed_type_block

  def resolve
    if resolution_required?
      new_content = content_block.content.dup
      new_content['embed_code'] = embed_code
      new_content['last_resolved_at'] = Time.zone.now

      # Save the updated content.
      content_block.update!(content: new_content)

      embed_code
    else
      content_block.content['embed_code']
    end
  end

  private

  def must_be_embed_type_block
    return if content_block.present? && content_block.block_type == ContentBlock::BLOCK_TYPE_EMBED

    errors[:base] << "Can only resolve embed-type content blocks"
  end

  def embed_code
    @embed_code ||= begin
      ::Oembed::Resolver.new(origin_url).embed_code
    rescue ::Oembed::Resolver::ProviderNotSupported
      nil
    end
  end

  def resolution_required?
    last_resolved_at = content_block&.content['last_resolved_at'] # rubocop:disable Lint/SafeNavigationChain

    return true if last_resolved_at.blank?

    Time.zone.parse(last_resolved_at) < 1.minute.ago
  end

  def origin_url
    url = content_block&.content['url'] # rubocop:disable Lint/SafeNavigationChain

    return url if url.present?

    raise "Unable to read URL for embed content block #{content_block_id}"
  end

  def content_block
    @content_block ||= ContentBlock.find_by(id: content_block_id)
  end

  def resource_school
    course&.school
  end

  def course
    content_block&.target_version&.target&.course
  end
end
