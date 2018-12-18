class Course < ApplicationRecord
  validates :name, presence: true

  belongs_to :school
  has_many :levels, dependent: :restrict_with_error
  has_many :target_groups, through: :levels
  has_many :targets, through: :target_groups
  has_many :faculty_course_enrollments, dependent: :destroy
  has_many :faculty, through: :faculty_course_enrollments

  def short_name
    name[0..2].upcase.strip
  end
end
