module Types
  class CreateAnswerLikeErrors < Types::BaseEnum
    value 'LikeExists', 'You have already liked the answer!'
    value 'BlankAnswerId', 'Answer id is required for adding a like'
  end
end
