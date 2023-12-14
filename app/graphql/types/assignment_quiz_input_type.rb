module Types
  class AssignmentQuizInputType < Types::BaseInputObject
    argument :question, String, required: true
    argument :answer_options, [Types::AssignmentQuizAnswerInputType], required: true
  end
end
