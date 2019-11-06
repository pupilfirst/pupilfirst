class CreateQuizSubmissionMutator < ApplicationQuery
  include AuthorizeStudent

  property :target_id, validates: { presence: { message: 'Blank Target Id' } }
  property :answer_ids

  validate :target_should_have_a_quiz
  validate :all_questions_answered
  validate :ensure_submittability

  def create_submission
    target.timeline_events.create!(
      founders: founders,
      description: result[:description],
      quiz_score: result[:score],
      passed_at: Time.zone.now,
      latest: true
    )
  end

  private

  def target_should_have_a_quiz
    return if quiz.present?

    errors[:base] << 'TargetDoesNotHaveQuiz'
  end

  def all_questions_answered
    return if number_of_questions == answers_from_user.count

    errors[:base] << "The answers are incomplete. Please try again."
  end

  def number_of_questions
    @number_of_questions ||= quiz.quiz_questions.count
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

  def result
    @result ||= begin
      score = 0
      intro = "Target _#{target.title}_ was completed by answering a quiz:"

      body = questions.each_with_index.map do |question, index|
        correct_answer = question.correct_answer
        u_answer = answers_from_user.where(quiz_question: question).first

        if correct_answer == u_answer
          score += 1
        end

        stripped_question = question.question.strip
        end_with_lb_or_space = stripped_question.ends_with?('```') ? "\n\n" : "  \n"

        "### Question #{index + 1}\n#{stripped_question}#{end_with_lb_or_space}#{answer_text(correct_answer, u_answer)}"
      end.join("\n\n")

      {
        score: "#{score}/#{number_of_questions}",
        description: "#{intro}\n\n#{body}"
      }
    end
  end

  def pretty_answer(answer)
    stripped_answer = answer.strip
    start_with_lb_or_space = stripped_answer.starts_with?('```') ? "\n" : " "
    end_with_lb_or_space = stripped_answer.ends_with?('```') ? "\n\n" : "  \n"
    "#{start_with_lb_or_space}#{stripped_answer}#{end_with_lb_or_space}"
  end

  def answer_text(correct_answer, u_answer)
    if u_answer == correct_answer
      "**Your Correct Answer:**#{pretty_answer(u_answer.value)}"
    else
      "**Your Answer:**#{pretty_answer(u_answer.value)}**Correct Answer:**#{pretty_answer(correct_answer.value)}"
    end
  end
end
