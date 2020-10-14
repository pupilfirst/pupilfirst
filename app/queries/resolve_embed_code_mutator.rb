class ResolveEmbedCodeMutator < ApplicationQuery
  include AuthorizeAuthor
  property :content_block_id, validates: { presence: true }

  validate :ensure_time_between_requests

  def resolve
    content_block.update!(
      content: { url: content_block.content['url'], request_source: content_block.content['request_source'], embed_code: embed_code, last_resolved_at: Time.zone.now },
    )
    embed_code
  end

  private

  def embed_code
    @embed_code ||= ::Oembed::Resolver.new(origin_url).embed_code
  rescue ::Oembed::Resolver::ProviderNotSupported
    nil
  end

  def ensure_time_between_requests
    last_resolved_at = content_block&.content['last_resolved_at'] # rubocop:disable Lint/SafeNavigationChain

    return if last_resolved_at.blank?

    time_since_last_resolved = Time.zone.now - Time.parse(last_resolved_at)

    return if time_since_last_resolved > 1.minute

    errors[:base] << 'URL was was resolved less than a minute ago. Please wait for a few minutes before trying again.'
  end

  def origin_url
    url = content_block&.content['url'] # rubocop:disable Lint/SafeNavigationChain

    return url if url.present?

    raise "Unable to find url for content block #{content_block_id}"
  end

  def content_block
    @content_block ||= ContentBlock.find_by(id: content_block_id)
  end

  def resource_school
    content_block&.target_version&.target&.course&.school
  end
end
