module Mutations
  class ResolveEmbedCode < ApplicationQuery
    include QueryAuthorizeAuthor

    description 'Resolve embed code for a given content block'

    field :embed_code, String, null: true

    argument :content_block_id, ID, required: true

    class MustBeEmbedBlockType < GraphQL::Schema::Validator
      def validate(_object, _context, value)
        content_block = ContentBlock.find_by(id: value[:content_block_id])

        return if content_block.block_type == ContentBlock::BLOCK_TYPE_EMBED

        'Can only resolve embed-type content blocks'
      end
    end

    validates MustBeEmbedBlockType => {}

    def resolve(_params)
      { embed_code: resolve_embed_code }
    end

    def resolve_embed_code
      ContentBlock.transaction do
        ContentBlocks::ResolveEmbedCodeService.new(content_block).execute
      end
    end

    def content_block
      @content_block ||= ContentBlock.find_by(id: @params[:content_block_id])
    end

    def resource_school
      course&.school
    end

    def course
      content_block&.target_version&.target&.course
    end
  end
end
