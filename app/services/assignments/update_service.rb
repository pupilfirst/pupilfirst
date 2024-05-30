module Assignments
  class UpdateService
    def initialize(assignment)
      @assignment = assignment
    end

    def execute(assignment_params)
      Assignment.transaction do
        @assignment.role = assignment_params[:role]
        @assignment.completion_instructions =
          assignment_params[:completion_instructions]
        @assignment.checklist = assignment_params[:checklist]

        handle_change_of_evaluation_criteria(
          assignment_params[:evaluation_criterion_ids]
        )

        @assignment.prerequisite_assignment_ids =
          get_assignment_ids_from_target_ids(
            assignment_params[:prerequisite_target_ids]
          )

        handle_milestone(assignment_params[:milestone])

        # If assignment archived remove all prerequisites
        if assignment_params[:archived] && !@assignment.archived
          Assignments::DetachFromPrerequisitesService.new([@assignment]).execute
        end

        @assignment.archived = assignment_params[:archived]
        @assignment.discussion = assignment_params[:discussion]
        @assignment.allow_anonymous = assignment_params[:allow_anonymous]

        @assignment.save!

        destroy_quiz if @assignment.quiz.present?

        if assignment_params[:quiz].present?
          recreate_quiz(assignment_params[:quiz])
        end

        @assignment
      end
    end

    private

    def handle_change_of_evaluation_criteria(evaluation_criteria_ids)
      if @assignment.evaluation_criterion_ids.blank? &&
           evaluation_criteria_ids.present?
        # Clear submissions without grades when assignment changes from auto-verified to evaluated.
        @assignment
          .target
          .timeline_events
          .where
          .missing(:timeline_event_grades)
          .destroy_all
      end
      @assignment.evaluation_criterion_ids = evaluation_criteria_ids
    end

    def get_assignment_ids_from_target_ids(target_ids)
      Assignment.where(target_id: target_ids).pluck(:id)
    end

    def handle_milestone(milestone_param)
      return if @assignment.milestone == milestone_param

      @assignment.milestone = milestone_param

      if milestone_param
        current_maximum_milestone_number =
          @assignment
            .target
            .course
            .targets
            .joins(:assignments)
            .maximum("assignments.milestone_number") || 0

        @assignment.milestone_number = current_maximum_milestone_number + 1
      else
        @assignment.milestone_number = nil
      end
    end

    def recreate_quiz(quiz)
      new_quiz =
        Quiz.create!(
          assignment_id: @assignment.id,
          title: @assignment.target.title
        )
      quiz.map do |quiz_question|
        new_quiz_question =
          QuizQuestion.create!(question: quiz_question.question, quiz: new_quiz)

        quiz_question.answer_options.map do |answer_option|
          if answer_option.correct_answer
            correct_answer =
              AnswerOption.create!(
                quiz_question_id: new_quiz_question.id,
                value: answer_option.answer
              )

            new_quiz_question.update!(correct_answer_id: correct_answer.id)
          else
            AnswerOption.create!(
              quiz_question_id: new_quiz_question.id,
              value: answer_option.answer
            )
          end
        end
      end
    end

    def destroy_quiz
      @assignment.quiz.quiz_questions.each do |quiz_question|
        quiz_question.answer_options.delete_all
      end

      @assignment.quiz.quiz_questions.destroy_all
      @assignment.quiz.destroy
    end
  end
end
