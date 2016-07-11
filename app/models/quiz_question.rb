class QuizQuestion < ActiveRecord::Base
  belongs_to :course_chapter
  has_many :answer_options
  accepts_nested_attributes_for :answer_options, allow_destroy: true

  validates_presence_of :question, :course_chapter_id
  # TODO: the following validation is busted! It seems to raise an error always.
  validate :must_have_one_correct_answer

  def must_have_one_correct_answer
    errors.add :base, 'Must have an option marked as the correct answer' unless correct_answer.present?
  end

  def correct_answer
    answer_options.where(correct_answer: true).first
  end
end
