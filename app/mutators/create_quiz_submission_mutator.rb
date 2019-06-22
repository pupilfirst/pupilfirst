class CreateQuizSubmissionMutator < ApplicationMutator
  include AuthorizeStudent

  attr_accessor :target_id
  attr_accessor :answer_ids

  validates :target_id, presence: { message: 'Blank Target Id' }

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

    errors[:base] << 'Please choose the correct target completion method.'
  end

  def all_questions_answered
    return if number_of_question == answers_from_user.count

    errors[:base] << "The answers are incomplete. Please try again."
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

  def result
    @result ||= begin
      score = 0
      intro = "Target '#{target.title}' was completed by answering a quiz:"

      body = questions.each_with_index.map do |question, index|
        correct_answer = question.correct_answer
        u_answer = answers_from_user.where(quiz_question: question).first

        if correct_answer == u_answer
          score += 1
        end

        "\nQ#{index + 1}: #{question.question}\n#{answer_text(question, correct_answer, u_answer)}"
      end.join("\n")

      {
        score: "#{score}/#{number_of_question}",
        description: "#{intro}\n#{body}"
      }
    end
  end

  def answer_text(question, correct_answer, u_answer)
    question.answer_options.each_with_index.map do |answer, index|
      "#{index + 1}. #{answer.value} #{result_text(answer, correct_answer, u_answer)}"
    end.join("\n")
  end

  def result_text(answer, correct_answer, u_answer)
    if (answer == correct_answer) && (answer == u_answer)
      '(Your correct answer)'
    elsif (answer == correct_answer) && (answer != u_answer)
      '(Correct answer)'
    elsif answer == u_answer
      '(Your answer)'
    else
      ''
    end
  end
end
