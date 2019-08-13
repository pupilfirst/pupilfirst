module Types
  class ContentType < Types::BaseUnion
    possible_types Types::ImageBlockType, Types::FileBlockType, Types::MarkdownBlockType, Types::EmbedBlockType
  end
end
