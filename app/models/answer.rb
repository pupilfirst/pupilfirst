class Answer < ApplicationRecord
  belongs_to :question
  belongs_to :creator, class_name: 'User'
  belongs_to :editor, class_name: 'User', optional: true
  belongs_to :archiver, class_name: 'User', optional: true
  has_many :answer_likes, dependent: :restrict_with_error
  has_many :comments, as: :commentable, dependent: :restrict_with_error
  has_one :school, through: :question
  has_many :text_versions, as: :versionable, dependent: :restrict_with_error
  has_one :community, through: :question
end
