module Types
  class AssignmentQuizAnswerInputType < Types::BaseInputObject
    argument :answer, String, required: true
    argument :correct_answer, Boolean, required: true
  end
end
