class CourseExport < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :course

  has_one_attached :file

  EXPORT_TYPE_STUDENTS = -'Students'
  EXPORT_TYPE_TEAMS = -'Teams'

  def self.valid_export_types
    [EXPORT_TYPE_STUDENTS, EXPORT_TYPE_TEAMS]
  end

  validates :export_type, inclusion: valid_export_types

  acts_as_taggable
end
