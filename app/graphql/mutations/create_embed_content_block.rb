module Mutations
  class CreateEmbedContentBlock < ApplicationQuery
    include QueryAuthorizeAuthor
    include ContentBlockCreatable

    argument :target_id, ID, required: true
    argument :above_content_block_id, ID, required: false
    argument :url, String, required: true
    argument :request_source, Types::EmbedRequestSource, required: true

    description 'Creates an embed content block.'

    field :content_block, Types::ContentBlockType, null: true

    def resolve(_params)
      { content_block: create_embed_content_block }
    end

    def create_embed_content_block
      ContentBlock.transaction do
        embed_block = create_embed_block
        if embed_block.content['embed_code'].nil? &&
             @params[:request_source] ==
               ContentBlock::EMBED_REQUEST_SOURCE_VIMEO
          Vimeo::ResolveEmbedCodeJob
            .set(wait: 5.minutes)
            .perform_later(embed_block.id, 1)
        end
        shift_content_blocks_below(embed_block)
        target_version.touch # rubocop:disable Rails/SkipsModelValidations
        json_attributes(embed_block)
      end
    end

    def embed_code
      @embed_code ||= ::Oembed::Resolver.new(@params[:url]).embed_code
    rescue ::Oembed::Resolver::ProviderNotSupported
      nil
    end

    def create_embed_block
      target_version.content_blocks.create!(
        block_type: ContentBlock::BLOCK_TYPE_EMBED,
        content: {
          url: @params[:url],
          request_source: @params[:request_source],
          embed_code: embed_code,
          last_resolved_at: Time.zone.now
        },
        sort_index: sort_index
      )
    end
  end
end
