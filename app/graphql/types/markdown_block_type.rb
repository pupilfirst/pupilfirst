module Types
  class MarkdownBlockType < Types::BaseObject
    field :markdown, String, null: false
    field :course_author_max_length, Integer, null: false
  end
end
