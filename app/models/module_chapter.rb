class ModuleChapter < ActiveRecord::Base
  belongs_to :course_module

  validates_presence_of :chapter_number, :name, :course_module_id
  validates_uniqueness_of :chapter_number, scope: :course_module_id
end
