module Levels
  class CloneService
    def initialize
      @assignment_id_translation = {}
    end

    def clone(source_level, target_course)
      Level.transaction do
        create_level(source_level, target_course).tap do |level|
          target_groups = create_target_groups(source_level, level)
          targets = create_targets(target_groups)
          create_content_blocks(targets)
          assignments = create_assignments(targets)
          create_quiz(assignments)
          create_prerequisites_assignments(assignments)
        end
      end
    end

    def create_level(source_level, target_course)
      new_level_number =
        if source_level.number.zero? && !target_course.levels.exists?(number: 0)
          0
        else
          (target_course.levels.maximum(:number) || 0) + 1
        end

      Level.create!(
        source_level
          .attributes
          .slice("name", "description")
          .merge(course: target_course, number: new_level_number)
      )
    end

    def create_target_groups(source_level, target_level)
      source_level
        .target_groups
        .where(archived: false)
        .map do |target_group|
          [
            target_group,
            TargetGroup.create!(
              target_group
                .attributes
                .slice("name", "description", "sort_index", "milestone")
                .merge(level: target_level)
            )
          ]
        end
    end

    def create_targets(target_groups)
      target_groups.flat_map do |old_target_group, new_target_group|
        old_target_group.targets.live.map do |old_target|
          new_target =
            Target.create!(
              old_target
                .attributes
                .slice(
                  "title",
                  "description",
                  "target_action_type",
                  "sort_index",
                  "visibility",
                  "resubmittable",
                  "role"
                )
                .merge(target_group: new_target_group)
            )
          [old_target, new_target]
        end
      end
    end

    def create_evaluation_criteria(source_evaluation_criteria, target_course)
      target_course.evaluation_criteria.find_by(
        name: source_evaluation_criteria.name,
        max_grade: source_evaluation_criteria.max_grade
      ) ||
        target_course.evaluation_criteria.create!(
          name: source_evaluation_criteria.name,
          max_grade: source_evaluation_criteria.max_grade,
          grade_labels: source_evaluation_criteria.grade_labels
        )
    end

    def create_assignment_evaluation_criteria(old_assignment, new_assignment)
      old_assignment.assignments_evaluation_criteria.each do |a_ec|
        new_assignment.assignments_evaluation_criteria.create!(
          evaluation_criterion:
            create_evaluation_criteria(
              a_ec.evaluation_criterion,
              new_assignment.course
            )
        )
      end
    end

    def create_content_blocks(targets)
      targets.each do |old_target, new_target|
        new_version = new_target.target_versions.create!
        old_target.current_content_blocks&.each do |content_block|
          old_content_block = content_block

          # create content block
          new_content_block =
            ContentBlock.create!(
              block_type: old_content_block.block_type,
              content: old_content_block.content,
              sort_index: old_content_block.sort_index,
              target_version: new_version
            )
          if old_content_block.file.attached?
            new_content_block.file.attach(old_content_block.file.blob)
          end
        end
      end
    end

    def create_assignments(targets)
      targets.flat_map do |old_target, new_target|
        old_target.assignments.map do |old_assignment|
          new_assignment =
            Assignment.create!(
              target: new_target,
              role: old_assignment.role,
              checklist: old_assignment.checklist,
              completion_instructions: old_assignment.completion_instructions,
              milestone: old_assignment.milestone,
              milestone_number: old_assignment.milestone_number,
              archived: old_assignment.archived,
              discussion: old_assignment.discussion,
              allow_anonymous: old_assignment.allow_anonymous
            )

          if old_assignment.evaluation_criteria.exists?
            create_assignment_evaluation_criteria(
              old_assignment,
              new_assignment
            )
          end
          @assignment_id_translation[old_assignment.id] = new_assignment.id

          [old_assignment, new_assignment]
        end
      end
    end

    def create_quiz(assignments)
      assignments.each do |old_assignment, new_assignment|
        next unless old_assignment.quiz?

        # create quiz
        old_quiz = old_assignment.quiz
        new_quiz =
          Quiz.create!(title: old_quiz.title, assignment: new_assignment)

        # create quiz questions
        old_quiz
          .quiz_questions
          .includes(:answer_options)
          .each do |old_quiz_question|
            new_quiz_question =
              QuizQuestion.create!(
                question: old_quiz_question.question,
                description: old_quiz_question.description,
                quiz_id: new_quiz.id
              )

            # create answer options
            old_quiz_question.answer_options.each do |old_answer_option|
              new_answer_option =
                AnswerOption.create!(
                  value: old_answer_option.value,
                  hint: old_answer_option.hint,
                  quiz_question_id: new_quiz_question.id
                )

              if old_quiz_question.correct_answer_id != old_answer_option.id
                next
              end

              # update correct answer
              new_quiz_question.update!(correct_answer: new_answer_option)
            end
          end
      end
    end

    def create_prerequisites_assignments(assignments)
      assignments.each do |old_assignment, new_assignment|
        next if old_assignment.prerequisite_assignment_ids.blank?

        # translate old prerequisite target ids
        new_assignment.prerequisite_assignment_ids =
          old_assignment.prerequisite_assignment_ids.map do |old_id|
            @assignment_id_translation[old_id]
          end
        new_assignment.save!
      end
    end
  end
end
