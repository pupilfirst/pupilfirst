module Courses
  # Creates a clone of a service with a new name.
  #
  # It copies all levels, target groups and targets, but leaves out student infomation and submissions, creating a fresh
  # course ready for modification and use.
  class CloneService
    def initialize(course)
      @course = course
      @target_id_translation = {}
    end

    def clone(new_name, school)
      Course.transaction do
        Course.create!(name: new_name,
                       description: @course.description,
                       grade_labels: @course.grade_labels,
                       max_grade: @course.max_grade,
                       pass_grade: @course.pass_grade,
                       school: school).tap do |new_course|
          levels = create_levels(new_course)
          target_groups = create_target_groups(levels)
          targets = create_targets(target_groups)
          create_content_blocks(targets)
          create_prerequisites_targets(targets)
          create_quiz(targets)
        end
      end
    end

    def create_levels(new_course)
      @course.levels.map do |level|
        [
          level,
          Level.create!(
            level.attributes
              .slice('name', 'description', 'number')
              .merge(course: new_course)
          )
        ]
      end
    end

    def create_target_groups(levels)
      levels.flat_map do |old_level, new_level|
        old_level.target_groups.where(archived: false).map do |target_group|
          [
            target_group,
            TargetGroup.create!(
              target_group.attributes
                .slice('name', 'description', 'sort_index', 'milestone')
                .merge(level: new_level)
            )
          ]
        end
      end
    end

    def create_targets(target_groups)
      target_groups.flat_map do |old_target_group, new_target_group|
        old_target_group.targets.live.map do |old_target|
          new_target = Target.create!(
            old_target.attributes
              .slice(
                'role', 'title', 'description', 'completion_instructions', 'target_action_type',
                'sort_index', 'link_to_complete', 'review_checklist', 'visibility', 'resubmittable'
              ).merge(target_group: new_target_group)
          )
          @target_id_translation[old_target.id] = new_target.id
          [old_target, new_target]
        end
      end
    end

    def create_content_blocks(targets)
      targets.each do |old_target, new_target|
        old_target.latest_content_versions&.each do |content_version|
          old_content_block = content_version.content_block
          # create content block
          new_content_block = ContentBlock.create!(
            block_type: old_content_block.block_type,
            content: old_content_block.content
          )
          new_content_block.file.attach(old_content_block.file.blob) if old_content_block.file.attached?

          # create content version
          ContentVersion.create!(
            target_id: new_target.id,
            content_block_id: new_content_block.id,
            version_on: content_version.version_on,
            sort_index: content_version.sort_index
          )
        end
      end
    end

    # rubocop:disable Metrics/MethodLength
    def create_quiz(targets)
      targets.each do |old_target, new_target|
        next unless old_target.quiz?

        # create quiz
        old_quiz = old_target.quiz
        new_quiz = Quiz.create!(title: old_quiz.title, target: new_target)

        # create quiz questions
        old_quiz.quiz_questions.includes(:answer_options).each do |old_quiz_question|
          new_quiz_question = QuizQuestion.create!(
            question: old_quiz_question.question,
            description: old_quiz_question.description,
            quiz_id: new_quiz.id
          )

          # create answer options
          old_quiz_question.answer_options.each do |old_answer_option|
            new_answer_option = AnswerOption.create!(
              value: old_answer_option.value,
              hint: old_answer_option.hint,
              quiz_question_id: new_quiz_question.id
            )

            next if old_quiz_question.correct_answer_id != old_answer_option.id

            # update correct answer
            new_quiz_question.update!(correct_answer: new_answer_option)
          end
        end
      end
    end

    # rubocop:enable Metrics/MethodLength

    def create_prerequisites_targets(targets)
      targets.each do |old_target, new_target|
        next if old_target.prerequisite_target_ids.blank?

        # translate old prerequisite target ids
        new_target.prerequisite_target_ids = old_target.prerequisite_target_ids.map { |old_id| @target_id_translation[old_id] }
        new_target.save!
      end
    end
  end
end
