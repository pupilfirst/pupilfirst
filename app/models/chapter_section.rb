class ChapterSection < ActiveRecord::Base
  belongs_to :course_module

  validates_presence_of :section_number, :name, :course_module_id
  validates_uniqueness_of :section_number, scope: :course_module_id
end
