class QuizQuestion < ApplicationRecord
  belongs_to :course_module
  has_many :answer_options
  accepts_nested_attributes_for :answer_options, allow_destroy: true

  validates :question, presence: true
  validates :course_module_id, presence: true

  # TODO: Valdiation below is broken. Suspect implementation of nested form by activeadmin + persistence issues. Disabling it except for persisted questions.
  validate :must_have_exactly_one_correct_answer

  def must_have_exactly_one_correct_answer
    return unless persisted?
    errors.add :base, 'Must have exactly one correct answer' unless exactly_one_correct_answer?
  end

  def exactly_one_correct_answer?
    # Answers might not be persisted yet. So we can't use the count short-hand as rubocop suggests
    answer_options.select { |o| o.correct_answer == true }.length == 1
  end

  def correct_answer
    answer_options.find_by(correct_answer: true)
  end
end
