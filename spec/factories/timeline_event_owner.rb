FactoryBot.define do
  factory :timeline_event_owner do
    timeline_event
    founder
    latest
  end
end
