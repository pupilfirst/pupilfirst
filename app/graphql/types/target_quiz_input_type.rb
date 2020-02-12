module Types
  class TargetQuizInputType < Types::BaseInputObject
    argument :question, String, required: true
    argument :answer_options, [Types::TargetQuizAnswerInputType], required: true
  end
end
