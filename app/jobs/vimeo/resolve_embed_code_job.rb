module Vimeo
  class ResolveEmbedCodeJob < ApplicationJob
    queue_as :default

    def perform(embed_block_id, attempt)
      embed_block = ContentBlock.find_by(id: embed_block_id)

      return if embed_block.nil?

      embed_code =
        ContentBlocks::ResolveEmbedCodeService.new(embed_block).execute
      max_attempts = Settings.vimeo_embed_max_retry_attempts
      if embed_code.nil? && attempt < max_attempts
        Vimeo::ResolveEmbedCodeJob
          .set(wait: (5 * attempt).minutes)
          .perform_later(embed_block_id, attempt + 1)
      end

      embed_code
    end
  end
end
