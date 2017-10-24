class EnglishQuizQuestion < ApplicationRecord
  has_many :answer_options, as: :quiz_question

  validates :question, presence: true
  mount_uploader :question, SlackImageAttachmentUploader
end
