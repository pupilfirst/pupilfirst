FactoryBot.define do
  factory :target do
    title { Faker::Lorem.words(number: 6).join " " }
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
        given_role { nil }
        given_milestone_number { nil }
        given_evaluation_criteria { nil }
      end

      after(:create) do |target, evaluator|
        assignment =
          create(:assignment, :with_default_checklist, target: target)

        # Update the assignment model based on the traits' transient variables
        # rubocop:disable Rails::SkipsModelValidations
        if evaluator.given_role.present?
          assignment.update_attribute(:role, evaluator.given_role)
        end
        if evaluator.given_milestone_number.present?
          assignment.update_attribute(
            :milestone_number,
            evaluator.given_milestone_number
          )
          assignment.update_attribute(:milestone, true)
        end
        if evaluator.given_evaluation_criteria.present?
          assignment.update_attribute(
            :evaluation_criteria,
            evaluator.given_evaluation_criteria
          )
        end
        # rubocop:enable Rails::SkipsModelValidations
      end
    end

    trait :with_group do
      target_group { nil } # We'll add it later.

      transient do
        milestone { false }
        level { create :level }
      end

      after(:build) do |target, evaluator|
        target.target_group =
          create(
            :target_group,
            level: evaluator.level,
            milestone: evaluator.milestone
          )
      end
    end
  end
end
