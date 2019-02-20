module Targets
  class CreateOrUpdateService
    def initialize(target)
      @target = target
    end

    def create_or_update(target_params)
      Target.transaction do
        @target.role = target_params[:role]
        @target.title = target_params[:title]
        @target.description = target_params[:title]
        @target.target_action_type = target_params[:target_action_type]
        @target.video_embed = target_params[:video_embed]
        @target.slideshow_embed = target_params[:slideshow_embed]
        @target.resource_ids = target_params[:resource_ids]
        @target.prerequisite_target_ids = target_params[:prerequisite_target_ids]
        @target.evaluation_criterion_ids = target_params[:evaluation_criterion_ids]
        @target.link_to_complete = target_params[:link_to_complete]

        @target.sort_index = sort_index if target_params[:sort_index].blank?
        @target.evaluation_criterion_ids = target_params[:evaluation_criterion_ids] if target_params[:evaluation_criterion_ids].present?
        @target.link_to_complete = target_params[:link_to_complete] if target_params[:link_to_complete].present?

        @target.save!

        recreate_quiz(target_params[:quiz]) if target_params[:quiz].present?

        @target
      end
    end

    private

    def recreate_quiz(quiz)
      new_quiz = Quiz.create!(target_id: @target.id, title: @target.title)

      quiz.map do |quiz_question|
        new_quiz_question = QuizQuestion.create!(question: quiz_question["question"], quiz: new_quiz)
        quiz_question["answerOption"].map do |answer_option|
          if answer_option["correctAnswer"]
            correct_answer = AnswerOption.create!(quiz_question_id: new_quiz_question.id, value: answer_option["answer"], hint: answer_option["hint"])
            new_quiz_question.update!(correct_answer_id: correct_answer.id)
          else
            AnswerOption.create!(quiz_question_id: new_quiz_question.id, value: answer_option["answer"], hint: answer_option["hint"])
          end
        end
      end
    end

    def sort_index
      max_index = @target.target_group.targets.maximum(:sort_index)
      max_index ? max_index + 1 : 1
    end
  end
end
