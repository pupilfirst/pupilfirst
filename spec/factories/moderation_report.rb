FactoryBot.define do
  factory :moderation_report do
    user
    reason { Faker::Lorem.sentence }

    association :reportable, factory: :timeline_event
  end
end
