module Types
  class CreateQuestionErrors < Types::BaseEnum
    value 'InvalidLengthTitle', 'Supplied title must be between 1 and 250 characters in length'
    value 'InvalidLengthDescription', 'Supplied description must be greater than 1 and characters in length'
    value 'BlankCommunityID', 'Community id is required for creating a Comment'
  end
end
