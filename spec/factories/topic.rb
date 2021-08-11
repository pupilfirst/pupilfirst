FactoryBot.define do
  factory :topic do
    title { Faker::Lorem.sentence }
    community
    last_activity_at { Time.zone.now }

    trait :with_first_post do
      transient { creator { create :user } }

      after(:create) do |topic, evaluator|
        create :post, :first_post, topic: topic, creator: evaluator.creator
      end
    end
  end
end
