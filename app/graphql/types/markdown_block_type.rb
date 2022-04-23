module Types
  class MarkdownBlockType < Types::BaseObject
    field :markdown, String, null: false
    field :markdown_course_author_max_length, Integer, null: false
  end
end
