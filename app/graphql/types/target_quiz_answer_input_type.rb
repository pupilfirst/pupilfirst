module Types
  class TargetQuizAnswerInputType < Types::BaseInputObject
    argument :answer, String, required: true
    argument :hint, String, required: false
    argument :correct_answer, Boolean, required: true
  end
end
