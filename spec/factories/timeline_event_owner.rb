FactoryBot.define do
  factory :timeline_event_owner do
    timeline_event
    student
    trait :latest do
      latest { true }
    end
  end
end
