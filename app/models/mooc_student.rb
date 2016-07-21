class MoocStudent < ActiveRecord::Base
  belongs_to :university
  belongs_to :user

  has_many :quiz_attempts
  has_many :course_chapters, through: :quiz_attempts

  def self.valid_semester_values
    %w(I II III IV V VI VII VIII Graduated Other)
  end

  def score
    # rubocop: disable SingleLineBlockParams
    CourseChapter.all.inject(0.0) { |sum, chapter| sum + score_for_chapter(chapter) } / CourseChapter.all.count
    # rubocop: enable SingleLineBlockParams
  end

  def score_for_chapter(chapter)
    quiz_attempts.where(course_chapter: chapter).order('created_at DESC').first&.score.to_i
  end
end
