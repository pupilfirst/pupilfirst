class EnglishQuizQuestion < ApplicationRecord
  validates :question, presence: true
  mount_uploader :question, SlackImageAttachmentUploader
end
