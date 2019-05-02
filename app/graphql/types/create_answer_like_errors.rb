module Types
  class CreateAnswerLikeErrors < Types::BaseEnum
    value 'LikeExist', 'You have already liked the answer!'
    value 'BlankAnswerId', 'Answer id is required for adding a like'
  end
end
