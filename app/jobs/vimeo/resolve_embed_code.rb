module Vimeo
  class ResolveEmbedCode < ApplicationJob
    queue_as :default

    def perform(embed_block)
      #To:do implement the exponential backoff schduling job login for resolving Vimeo Uploads
      ContentBlocks::ResolveEmbededCode.new(embed_block).execute
    end
  end
end
