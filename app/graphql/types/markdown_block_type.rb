module Types
  class MarkdownBlockType < Types::BaseObject
    field :markdown, String, null: false
    field :markdown_content_block_maximum_length, Integer, null: false
  end
end
