FactoryBot.define do
  factory :timeline_event do
    checklist do
      [
        {
          "kind" => Assignment::CHECKLIST_KIND_LONG_TEXT,
          "title" => Faker::Lorem.sentence,
          "result" => Faker::Lorem.sentence,
          "status" => TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
        }
      ]
    end

    target

    trait :passed do
      passed_at { 1.day.ago }
    end

    trait :has_checklist_with_file do
      transient { timeline_event_file { create(:timeline_event_file) } }

      timeline_event_files { [timeline_event_file] }

      checklist do
        [
          {
            "kind" => Assignment::CHECKLIST_KIND_LONG_TEXT,
            "title" => Faker::Lorem.sentence,
            "result" => Faker::Lorem.sentence,
            "status" => TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
          },
          {
            "kind" => Assignment::CHECKLIST_KIND_FILES,
            "title" => Faker::Lorem.sentence,
            "result" => [timeline_event_file.id],
            "status" => TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
          }
        ]
      end
    end

    trait :evaluated do
      evaluated_at { 1.day.ago }
      evaluator { create :faculty }
    end

    trait :with_owners do
      transient do
        owners { Student.none }
        latest { false }
      end

      after(:create) do |submission, evaluator|
        evaluator.owners.each do |owner|
          create(
            :timeline_event_owner,
            latest: evaluator.latest,
            student: owner,
            timeline_event: submission
          )
        end
      end
    end
  end
end
