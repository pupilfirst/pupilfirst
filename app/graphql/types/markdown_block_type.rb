module Types
  class MarkdownBlockType < Types::BaseObject
    field :markdown, String, null: false
    field :curriculum_editor_max_length, Integer, null: false
  end
end
