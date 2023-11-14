FactoryBot.define do
  factory :target do
    title { Faker::Lorem.words(number: 6).join ' ' }
    role {Target.valid_roles.sample}
    target_group
    sequence(:sort_index)
    visibility { Target::VISIBILITY_LIVE }

    trait :archived do
      safe_to_change_visibility { true }
      visibility { Target::VISIBILITY_ARCHIVED }
    end

    trait :draft do
      safe_to_change_visibility { true }
      visibility { Target::VISIBILITY_DRAFT }
    end

    trait :session do
      session_at { 1.week.from_now }
      days_to_complete { nil }
    end

    trait :with_markdown do
      after(:create) do |target|
        target_version = create(:target_version, target: target)
        create(:content_block, :empty_markdown, target_version: target_version)
      end
    end

    trait :with_content do
      after(:create) do |target|
        target_version = create(:target_version, target: target)
        create(:content_block, :image, target_version: target_version)
        create(:content_block, :markdown, target_version: target_version)
        create(:content_block, :file, target_version: target_version)
        create(:content_block, :embed, target_version: target_version)
      end
    end

    trait :with_file do
      after(:create) do |target|
        target_version = create(:target_version, target: target)
        create(:content_block, :file, target_version: target_version)
      end
    end

    trait :with_shared_assignment do
      transient do
        shared_assignment { true }
        given_role { nil }
        given_milestone_number { nil }
        given_evaluation_criteria { nil }
        given_checklist { nil }
        given_prerequisite_targets { nil }
        given_quiz { nil }
        with_quiz {nil}
        with_evaluation_criterion {false}
        with_completion_instructions { nil }
      end

      after(:create) do |target, evaluator|
        if evaluator.shared_assignment
          # Choose which type of assignment to create
          if evaluator.with_evaluation_criterion
            assignment = create(:assignment,:with_evaluation_criterion, :with_default_checklist, target: target)
          elsif evaluator.with_quiz
            assignment = create(:assignment, target: target)
            quiz = create(:quiz, :with_question_and_answers, assignment: assignment) # rubocop:disable Lint::UselessAssignment
          else
            assignment = create(:assignment,:with_default_checklist, target: target)
          end

          prerequisite_assignments = Assignment.where(target: evaluator.given_prerequisite_targets).to_a

          # Update the assignment model based on the traits' transient variables
          # rubocop:disable Rails::SkipsModelValidations
          assignment.update_attribute(:role, evaluator.given_role) if evaluator.given_role.present?
          assignment.update_attribute(:milestone_number, evaluator.given_milestone_number) if evaluator.given_milestone_number.present?
          assignment.update_attribute(:milestone, true) if evaluator.given_milestone_number.present?
          assignment.update_attribute(:evaluation_criteria, evaluator.given_evaluation_criteria) if evaluator.given_evaluation_criteria.present?
          assignment.update_attribute(:checklist, evaluator.given_checklist) if evaluator.given_checklist.present?
          assignment.update_attribute(:quiz, evaluator.given_quiz) if evaluator.given_quiz.present?
          assignment.update_attribute(:prerequisite_assignments, prerequisite_assignments) if evaluator.given_prerequisite_targets.present?
          assignment.update_attribute(:completion_instructions, Faker::Lorem.sentence) if evaluator.with_completion_instructions
          # rubocop:enable Rails::SkipsModelValidations
        end
      end
    end

    # trait :with_shared_assignment, given_role: Assignment::ROLE_STUDENT do
    #   after(:create) do |target|
    #     assignment = create :assignment, :with_shared_assignment, given_role: Assignment::ROLE_STUDENT, target: target
    #     target.reload
    #   end
    # end

    # trait :for_team do
    #   after(:create) do |target|
    #     assignment = create :assignment, :for_team, target: target
    #     target.reload
    #   end
    # end

    # trait :team do
    #   after(:create) do |target|
    #     assignment = create :assignment, :team, target: target
    #     target.reload
    #   end
    # end

    # trait :student do
    #   after(:create) do |target|
    #     assignment = create :assignment, :student, target: target
    #     target.reload
    #   end
    # end

    # trait :with_given_evaluation_criteria do
    #   transient do
    #     given_evaluation_criteria {[]}
    #   end
    #   after(:build) do |target, evaluator|
    #     assignment = create :assignment, target: target, evaluation_criteria: evaluator.given_evaluation_criteria
    #     target.reload
    #   end
    # end

    # trait :with_given_milestone do
    #   transient do
    #     given_milestone_number {nil}
    #   end
    #   after(:build) do |target, evaluator|
    #     assignment = create :assignment, target: target, milestone: true, milestone_number: evaluator.given_milestone_number
    #     target.reload
    #   end
    # end

    # trait :with_given_evaluation_criteria_and_milestone do
    #   transient do
    #     given_evaluation_criteria {[]}
    #     given_milestone_number {nil}
    #   end
    #   after(:build) do |target, evaluator|
    #     assignment = create :assignment, target: target, evaluation_criteria: evaluator.given_evaluation_criteria, milestone: true, milestone_number: evaluator.given_milestone_number
    #     target.reload
    #   end
    # end

    # trait :with_quiz do
    #   after(:create) do |target|
    #     assignment = create :assignment, target: target
    #     quiz = create :quiz, assignment: assignment
    #     target.reload
    #   end
    # end

    # trait :with_quiz_and_given_milestone do
    #   transient do
    #     given_milestone_number {10}
    #   end
    #   after(:build) do |target, evaluator|
    #     assignment = create :assignment, target: target, milestone: true, milestone_number: evaluator.given_milestone_number
    #     quiz = create :quiz, assignment: assignment
    #     target.reload
    #   end
    # end

    trait :with_group do
      target_group { nil } # We'll add it later.

      transient do
        milestone { false }
        level { create :level }
      end

      after(:build) do |target, evaluator|
        target.target_group = create(:target_group, level: evaluator.level, milestone: evaluator.milestone)
      end
    end
  end
end
