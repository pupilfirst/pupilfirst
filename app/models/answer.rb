class Answer < ApplicationRecord
  belongs_to :question
  belongs_to :user
  has_many :answer_likes, dependent: :restrict_with_error
  has_many :comments, as: :commentable, dependent: :restrict_with_error
  has_one :school, through: :question
  has_many :markdown_versions, as: :versionable, dependent: :restrict_with_error
end
