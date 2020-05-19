class TargetDetailsResolver < ApplicationQuery
  property :target_id

  def target_details
    {
      title: target.title,
      role: target.role,
      quiz: quiz,
      target_group_id: target.target_group_id,
      evaluation_criteria: target.evaluation_criteria.pluck(:id),
      prerequisite_targets: target.prerequisite_targets.pluck(:id),
      completion_instructions: target.completion_instructions,
      link_to_complete: target.link_to_complete,
      visibility: target.visibility,
      checklist: target.checklist,
    }
  end

  def authorized?
    return false if target&.course&.school != current_school

    current_school_admin.present? || current_user&.course_authors&.where(course: target.course).present?
  end

  def target
    @target ||= Target.includes(quiz: { quiz_questions: %I[answer_options correct_answer] }).find_by(id: target_id)
  end

  def quiz
    if target.quiz.present?
      target.quiz.quiz_questions.map do |quiz_question|
        {
          id: quiz_question.id,
          question: quiz_question.question,
          answer_options: answer_options(quiz_question),
        }
      end
    else
      []
    end
  end

  def answer_options(quiz_question)
    quiz_question.answer_options.map do |answer_option|
      {
        id: answer_option.id,
        answer: answer_option.value,
        hint: answer_option.hint,
        correct_answer: correct_answer?(quiz_question, answer_option),
      }
    end
  end

  def correct_answer?(quiz_question, answer_option)
    quiz_question.correct_answer == answer_option
  end
end
