class CourseCategory < ApplicationRecord
  belongs_to :school

  validates :name, presence: true
end
