FactoryBot.define do
  factory :assignment do
    role { Assignment.valid_roles.sample }
    archived { false }
    milestone { false }
    target

    trait :for_student do
      role { Assignment::ROLE_STUDENT }
    end

    trait :for_team do
      role { Assignment::ROLE_TEAM }
    end

    trait :team do
      role { Assignment::ROLE_TEAM }
    end

    trait :student do
      role { Assignment::ROLE_STUDENT }
    end

    trait :with_default_checklist do
      checklist do
        [
          {
            kind: Assignment::CHECKLIST_KIND_LONG_TEXT,
            title: "Write something about your submission",
            optional: false
          }
        ]
      end
    end

    trait :with_completion_instructions do
      completion_instructions { Faker::Lorem.sentence }
    end

    trait :with_evaluation_criterion do
      after(:create) do |assignment|
        evaluation_criteria =
          create :evaluation_criterion, course: assignment.course
        create :assignments_evaluation_criterion,
               assignment: assignment,
               evaluation_criterion: evaluation_criteria
        assignment.reload
      end
    end
  end
end
