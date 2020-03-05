FactoryBot.define do
  factory :timeline_event do
    checklist { [{ "kind" => Target::CHECKLIST_KIND_LONG_TEXT, "title" => Faker::Lorem.sentence, "result" => Faker::Lorem.sentence, "status" => TimelineEvent::CHECKLIST_STATUS_NO_ANSWER }] }
    target

    trait :passed do
      passed_at { 1.day.ago }
    end

    trait(:latest) do
      latest { true }
    end
  end
end
