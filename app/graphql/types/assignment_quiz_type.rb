module Types
  class AssignmentQuizType < Types::BaseObject
    field :id, ID, null: false
    field :question, String, null: false
    field :answer_options, [Types::AssignmentQuizAnswerType], null: false
  end
end
