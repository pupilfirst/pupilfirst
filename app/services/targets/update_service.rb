module Targets
  class UpdateService
    def initialize(target)
      @target = target
    end

    def execute(target_params)
      Target.transaction do
        @target.role = target_params[:role]
        @target.title = target_params[:title]
        @target.target_action_type = Target::TYPE_TODO
        @target.link_to_complete = target_params[:link_to_complete]
        @target.resubmittable = target_params[:evaluation_criterion_ids].present?
        @target.link_to_complete = target_params[:link_to_complete]
        @target.completion_instructions = target_params[:completion_instructions]
        @target.checklist = target_params[:checklist]

        handle_target_group_change(target_params[:target_group_id]) if target_params[:target_group_id].to_i != @target.target_group_id
        handle_change_of_evaluation_criteria(target_params[:evaluation_criterion_ids])
        @target.prerequisite_target_ids = target_params[:prerequisite_target_ids]

        @target.save!

        destroy_quiz if @target.quiz.present?

        recreate_quiz(target_params[:quiz]) if target_params[:quiz].present?

        update_visibility(target_params[:visibility])

        @target
      end
    end

    private

    def handle_change_of_evaluation_criteria(evaluation_criteria_ids)
      if @target.evaluation_criterion_ids.blank? && evaluation_criteria_ids.present?
        # Clear submissions without grades when target changes from auto-verified to evaluated.
        TimelineEvent.left_joins(:timeline_event_grades)
          .where(target: @target, timeline_event_grades: { id: nil })
          .destroy_all
      end
      @target.evaluation_criterion_ids = evaluation_criteria_ids
    end

    def handle_target_group_change(new_target_group_id)
      new_target_group = TargetGroup.find(new_target_group_id)
      @target.sort_index = (new_target_group.targets.maximum(:sort_index).to_i + 1)

      if @target.target_group.level_id != new_target_group.level_id
        Targets::DetachFromPrerequisitesService.new([@target]).execute
      end

      @target.target_group = new_target_group
    end

    def recreate_quiz(quiz)
      new_quiz = Quiz.create!(target_id: @target.id, title: @target.title)
      quiz.map do |quiz_question|
        new_quiz_question = QuizQuestion.create!(question: quiz_question["question"], quiz: new_quiz)
        quiz_question["answerOptions"].map do |answer_option|
          if answer_option["correctAnswer"]
            correct_answer = AnswerOption.create!(quiz_question_id: new_quiz_question.id, value: answer_option["answer"])
            new_quiz_question.update!(correct_answer_id: correct_answer.id)
          else
            AnswerOption.create!(quiz_question_id: new_quiz_question.id, value: answer_option["answer"])
          end
        end
      end
    end

    def destroy_quiz
      @target.quiz.quiz_questions.each do |quiz_question|
        quiz_question.answer_options.delete_all
      end
      @target.quiz.quiz_questions.destroy_all
      @target.quiz.destroy
    end

    def update_visibility(visibility)
      ::Targets::UpdateVisibilityService.new(@target, visibility).execute
    end
  end
end
