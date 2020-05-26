FactoryBot.define do
  factory :timeline_event_owner do
    timeline_event
    founder
    trait :latest do
      latest { true }
    end
  end
end
