class AnswerOption < ActiveRecord::Base
  belongs_to :quiz_question
end
