class CreateQuizSubmissionMutator < ApplicationMutator
  attr_accessor :target_id
  attr_accessor :answer_ids

  validates :target_id, presence: { message: 'Blank Target Id' }

  validate :target_should_have_a_quiz
  validate :all_questions_answered
  validate :pending_submission

  def pending_submission
    return if founder.timeline_events.where(target_id: target_id).blank?

    errors[:base] << 'You cannot resubmit the target'
  end

  def target_should_have_a_quiz
    return if quiz.present?

    errors[:base] << 'Please choose the correct target completion method.'
  end

  def all_questions_answered
    return if number_of_question == answers_from_user.count

    errors[:base] << "The answers are incomplete. Please try again."
  end

  def create_submission
    @target.timeline_events.create!(
      founders: founders,
      description: description,
      passed_at: Time.zone.now,
      latest: true
    )
    true
  end

  private

  def authorized?
    current_school.present? && course.school == current_school && founder.present?
  end

  def founder
    @founder ||= current_user.founders.joins(:level).where(levels: { course_id: course }).first
  end

  def number_of_question
    @number_of_question ||= quiz.quiz_questions.count
  end

  def answers_from_user
    @answers_from_user ||= quiz.answer_options.where(id: answer_ids)
  end

  def questions
    @questions ||= quiz.quiz_questions
  end

  def quiz
    @quiz ||= target.quiz
  end

  def course
    @course ||= target.course
  end

  def target
    @target ||= Target.find_by(id: target_id)
  end

  def description
    score = 0
    description_text = ""
    intro_text = "Target '#{target.title}' was automatically marked complete."

    questions.each_with_index do |question, index|
      correct_answer = question.correct_answer
      u_answer = answers_from_user.where(quiz_question: question).first

      if correct_answer == u_answer
        score += 1
      end

      description_text = "#{description_text}
      \n Q#{index + 1}: #{question.question}
      \n Answers: #{question.answer_options.pluck(:value).join(', ')}
      \n Correct Answer: #{correct_answer.value}
      \n Your Answer: #{u_answer.value}
      \n"
    end

    "#{intro_text} \n Score - #{score}/#{number_of_question} #{description_text}"
  end

  def founders
    if @target.founder_event?
      [@founder]
    else
      @founder.startup.founders
    end
  end
end
