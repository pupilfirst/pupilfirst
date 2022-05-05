class QuizQuestion < ApplicationRecord
  belongs_to :quiz
  has_many :answer_options, dependent: :restrict_with_error
  belongs_to :correct_answer, optional: true, class_name: 'AnswerOption'

  accepts_nested_attributes_for :answer_options, allow_destroy: true

  validates :question, presence: true

  validate :correct_answer_must_be_one_of_possible_answers

  def correct_answer_must_be_one_of_possible_answers
    return unless persisted?
    return if answer_options.blank?
    return if answer_options.where(id: correct_answer&.id).present?

    errors[:correct_answer_id] << 'must be one of the possible answers'
  end
end
