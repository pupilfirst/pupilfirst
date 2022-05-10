module Vimeo
  class ResolveEmbedCode < ApplicationJob
    queue_as :default

    def perform(embed_block, attempt)
      #To:Do get the attempt count from env
      embed_code = ContentBlocks::ResolveEmbededCode.new(embed_block).execute
      if embed_code.nil? && attempt <= 4
        Vimeo::ResolveEmbedCode
          .set(wait: (5 * attempt).minutes)
          .perform_later(embed_block, attempt + 1)
      end
      embed_code
    end
  end
end
