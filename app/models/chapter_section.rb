class ChapterSection < ActiveRecord::Base
  belongs_to :course_chapter

  validates_presence_of :section_number, :name, :course_chapter_id
  validates_uniqueness_of :section_number, scope: :course_chapter_id
end
