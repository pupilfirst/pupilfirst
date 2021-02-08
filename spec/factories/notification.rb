FactoryBot.define do
  factory :notification do
    message { Faker::Lorem.sentence }
    event { Notification.events.keys.sample }
    actor
    trait(:read) { read_at { 1.day.ago } }
    recipient
  end
end
