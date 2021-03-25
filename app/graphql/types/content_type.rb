module Types
  class ContentType < Types::BaseUnion
    possible_types Types::ImageBlockType, Types::FileBlockType, Types::MarkdownBlockType, Types::EmbedBlockType,
      Types::CoachingSessionBlockType, Types::PdfDocumentBlockType

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
        when ContentBlock::BLOCK_TYPE_COACHING_SESSION
          Types::CoachingSessionBlockType
        when ContentBlock::BLOCK_TYPE_PDF_DOCUMENT
          Types::PdfDocumentBlockType
      end
    end
  end
end
