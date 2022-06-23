module Vimeo
  class ResolveEmbedCodeJob < ApplicationJob
    queue_as :default

    def perform(embed_block, attempt)
      embed_code = ContentBlocks::ResolveEmbededCode.new(embed_block).execute
      max_attempts = Rails.application.secrets.vimeo_embed_max_retry_attempts
      if embed_code.nil? && attempt <= max_attempts
        Vimeo::ResolveEmbedCode
          .set(wait: (5 * attempt).minutes)
          .perform_later(embed_block, attempt + 1)
      end
      embed_code
    end
  end
end
