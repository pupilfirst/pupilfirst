FactoryGirl.define do
  factory :timeline_event do
    startup
    description { Faker::Lorem.words(10).join ' ' }
    event_on { 1.month.from_now }
    timeline_event_type
  end
end
