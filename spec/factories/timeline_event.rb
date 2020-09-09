FactoryBot.define do
  factory :timeline_event do
    checklist { [{ "kind" => Target::CHECKLIST_KIND_LONG_TEXT, "title" => Faker::Lorem.sentence, "result" => Faker::Lorem.sentence, "status" => TimelineEvent::CHECKLIST_STATUS_NO_ANSWER }] }
    target

    trait :passed do
      passed_at { 1.day.ago }
    end

    trait :evaluated do
      evaluated_at { 1.day.ago }
      evaluator { create :faculty }
    end

    trait :with_owners do
      transient do
        owners { Founder.none }
        latest { false }
      end

      after(:create) do |submission, evaluator|
        evaluator.owners.each do |owner|
          create(:timeline_event_owner, latest: evaluator.latest, founder: owner, timeline_event: submission)
        end
      end
    end
  end
end

