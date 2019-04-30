module Types
  class CreateAnswerErrors < Types::BaseEnum
    value 'InvalidLengthAnswer', 'Supplied comment must be greater than 1 characters in length'
    value 'BlankQuestionId', 'Question id is required for creating a Comment'
  end
end
