module Types
  class TargetQuizAnswerType < Types::BaseObject
    field :id, ID, null: false
    field :answer, String, null: false
    field :hint, String, null: true
    field :correct_answer, Boolean, null: false
  end
end
