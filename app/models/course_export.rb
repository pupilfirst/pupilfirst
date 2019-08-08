class CourseExport < ApplicationRecord
  belongs_to :user
  belongs_to :course

  has_one_attached :file
end
