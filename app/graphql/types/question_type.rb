module Types
  class QuestionType < Types::BaseObject
    field :id, ID, null: false
    field :title, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :answers_count, Integer, null: false
  end
end
