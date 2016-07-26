class QuizQuestion < ActiveRecord::Base
  belongs_to :course_chapter
  has_many :answer_options
  accepts_nested_attributes_for :answer_options, allow_destroy: true

  validates_presence_of :question, :course_chapter_id, :question_number
  validates_uniqueness_of :question_number, scope: :course_chapter_id

  validate :must_have_exactly_one_correct_answer

  def must_have_exactly_one_correct_answer
    errors.add :base, 'Must have exactly one correct answer' unless exactly_one_correct_answer?
  end

  def exactly_one_correct_answer?
    # Answers might not be persisted yet. So we can't use the count short-hand as rubocop suggests
    # rubocop: disable Performance/Count
    answer_options.select { |o| o.correct_answer == true }.count == 1
    # rubocop: enable Performance/Count
  end

  def correct_answer
    answer_options.where(correct_answer: true).first
  end
end
