class EnglishQuizQuestion < ApplicationRecord
  has_many :answer_options, as: :quiz_question, inverse_of: :quiz_question, dependent: :destroy
  accepts_nested_attributes_for :answer_options, allow_destroy: true
  has_one :correct_answer, -> { where(correct_answer: true) }, class_name: 'AnswerOption', as: :quiz_question, dependent: :destroy, inverse_of: :quiz_question
  has_many :english_quiz_submissions, dependent: :restrict_with_error

  validates :question, presence: true
  validates :answer_options, length: { minimum: 2 }

  mount_uploader :question, SlackImageAttachmentUploader
end
