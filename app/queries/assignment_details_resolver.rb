class AssignmentDetailsResolver < ApplicationQuery
  property :target_id

  def assignment_details
    if assignment
      {
        role: assignment.role,
        quiz: quiz,
        evaluation_criteria: assignment.evaluation_criteria.pluck(:id),
        prerequisite_targets:
          target_ids_from_assignment_ids(
            assignment.prerequisite_assignments.not_archived.pluck(:id)
          ),
        completion_instructions: assignment.completion_instructions,
        checklist: assignment.checklist,
        milestone: assignment.milestone?,
        archived: assignment.archived?,
        discussion: assignment.discussion?,
        allow_anonymous: assignment.allow_anonymous?
      }
    else
      nil
    end
  end

  def authorized?
    return false if target&.course&.school != current_school

    current_school_admin.present? ||
      current_user&.course_authors&.where(course: target.course).present?
  end

  def target
    @target ||= Target.find_by(id: target_id)
  end

  def assignment
    @assignment ||=
      Assignment.includes(
        quiz: {
          quiz_questions: %I[answer_options correct_answer]
        }
      ).find_by(target_id: target_id)
  end

  def target_ids_from_assignment_ids(assignment_ids)
    Assignment.where(id: assignment_ids).pluck(:target_id)
  end

  def quiz
    if assignment.quiz.present?
      assignment.quiz.quiz_questions.map do |quiz_question|
        {
          id: quiz_question.id,
          question: quiz_question.question,
          answer_options: answer_options(quiz_question)
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
        correct_answer: correct_answer?(quiz_question, answer_option)
      }
    end
  end

  def correct_answer?(quiz_question, answer_option)
    quiz_question.correct_answer == answer_option
  end
end
