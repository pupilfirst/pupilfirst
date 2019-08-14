module Types
  class ContentType < Types::BaseUnion
    possible_types Types::ImageBlockType, Types::FileBlockType, Types::MarkdownBlockType, Types::EmbedBlockType

    def self.resolve_type(object, _context)
      case object[:block_type]
        when ContentBlock::BLOCK_TYPE_MARKDOWN
          Types::MarkdownBlockType
        when ContentBlock::BLOCK_TYPE_IMAGE
          Types::ImageBlockType
        when ContentBlock::BLOCK_TYPE_FILE
          Types::FileBlockType
        when ContentBlock::BLOCK_TYPE_EMBED
          Types::EmbedBlockType
      end
    end
  end
end
