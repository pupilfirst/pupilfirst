class Question < ApplicationRecord
  belongs_to :community
  belongs_to :user
  has_many :target, dependent: :restrict_with_error
  has_many :answers, dependent: :restrict_with_error
  has_many :comments, as: :commentable, dependent: :restrict_with_error
  has_one :school, through: :community

  has_many :target_questions, dependent: :destroy
  has_many :targets, through: :target_questions
  has_many :markdown_versions, as: :versionable, dependent: :restrict_with_error
end
