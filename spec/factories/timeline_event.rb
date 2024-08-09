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
      transient { file_user { create(:user) } }

      timeline_event_files do
        # We'll set `timeline_event` to `nil` here, but it'll get set to the correct ID
        # when this `timeline_event_files` assignment is completed.
        [create(:timeline_event_file, user: file_user, timeline_event: nil)]
      end

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
            "result" => [timeline_event_files.first.id.to_s],
            "status" => TimelineEvent::CHECKLIST_STATUS_NO_ANSWER
          }
        ]
      end
    end

    trait :has_checklist_with_image_file do
      transient { file_user { create(:user) } }

      timeline_event_files do
        # We'll set `timeline_event` to `nil` here, but it'll get set to the correct ID
        # when this `timeline_event_files` assignment is completed.
        [
          create(
            :timeline_event_file,
            :image,
            user: file_user,
            timeline_event: nil
          )
        ]
      end

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
            "result" => [timeline_event_files.first.id.to_s],
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
