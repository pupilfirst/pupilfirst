module Types
  class UpdateQuestionErrors < Types::BaseEnum
    value 'InvalidLengthTitle', 'Supplied title must be between 1 and 250 characters in length'
    value 'InvalidLengthDescription', 'Supplied description must be greater than 1 characters in length'
  end
end
