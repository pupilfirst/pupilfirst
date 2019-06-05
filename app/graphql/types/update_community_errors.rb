module Types
  class UpdateCommunityErrors < Types::BaseEnum
    value 'InvalidLengthName', 'Supplied title must be between 1 and 50 characters in length'
    value 'IncorrectCourseIds', 'The list of courses selected are incorrect'
    value 'IncorrectCommunityId', 'Community does not exist'
  end
end
