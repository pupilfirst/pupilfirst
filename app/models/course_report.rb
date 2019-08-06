class CourseReport < ApplicationRecord
  belongs_to :user
  belongs_to :course

  has_one_attached :file

  validates :token, presence: true, uniqueness: true
end
