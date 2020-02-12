module Types
  class TargetQuizType < Types::BaseObject
    field :id, ID, null: false
    field :question, String, null: false
    field :answer_options, [Types::TargetQuizAnswerType], null: false
  end
end
