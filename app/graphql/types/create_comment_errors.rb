module Types
  class CreateCommentErrors < Types::BaseEnum
    value 'InvalidCommentableType', 'Supplied type must be one of "Question" or "Answer"'
    value 'InvalidLengthValue', 'Supplied comment must be greater than 1 characters in length'
    value 'BlankCommentableId', 'Commentable id is required for creating a Comment'
  end
end
