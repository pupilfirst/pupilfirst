module Schools
  module Curricula
    class ShowPresenter < ApplicationPresenter
      def initialize(view_context, course)
        super(view_context)

        @course = course
      end

      def react_props
        {
          course: course_data,
          evaluationCriteria: evaluation_criteria,
          levels: levels,
          targetGroups: target_groups,
          targets: targets,
          contentBlocks: content_blocks,
          authenticityToken: view.form_authenticity_token
        }
      end

      def course_data
        {
          id: @course.id,
          name: @course.name
        }
      end

      def content_blocks
        ContentBlock.where(target: @course.targets).map do |content_block|
          {
            id: content_block.id,
            targetId: content_block.target.id,
            sortIndex: content_block.sort_index,
            content: content_block.content,
            blockType: content_block.block_type
          }
        end
      end

      def evaluation_criteria
        @course.evaluation_criteria.map do |criteria|
          {
            id: criteria.id,
            name: criteria.name
          }
        end
      end

      def levels
        @course.levels.map do |level|
          {
            id: level.id,
            name: level.name,
            number: level.number,
            unlockOn: level.unlock_on
          }
        end
      end

      def target_groups
        @course.target_groups.map do |target_group|
          {
            id: target_group.id,
            name: target_group.name,
            description: target_group.description,
            levelId: target_group.level_id,
            milestone: target_group.milestone,
            sortIndex: target_group.sort_index,
            archived: target_group.archived
          }
        end
      end

      def targets
        @course.targets.map do |target|
          {
            id: target.id,
            targetGroupId: target.target_group_id,
            title: target.title,
            evaluationCriteria: evaluation_criteria_for_target(target),
            prerequisiteTargets: prerequisite_targets(target),
            quiz: quiz(target),
            linkToComplete: target.link_to_complete,
            role: target.role,
            targetActionType: target.target_action_type,
            sortIndex: target.sort_index,
            visibility: target.visibility
          }
        end
      end

      private

      def evaluation_criteria_for_target(target)
        target.evaluation_criteria.pluck(:id)
      end

      def prerequisite_targets(target)
        target.prerequisite_targets.pluck(:id)
      end

      def target_resources(target)
        target.resources.map do |resource|
          {
            id: resource.id,
            title: resource.title
          }
        end
      end

      def quiz(target)
        if target.quiz.present?
          target.quiz.quiz_questions.map do |quiz_question|
            {
              id: quiz_question.id,
              question: quiz_question.question,
              answerOptions: answer_options(quiz_question)
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
            correctAnswer: correct_answer?(quiz_question, answer_option)
          }
        end
      end

      def correct_answer?(quiz_question, answer_option)
        quiz_question.correct_answer == answer_option
      end
    end
  end
end
