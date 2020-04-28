FactoryBot.define do
  factory :topic do
    title { Faker::Lorem.sentence }
    community

    trait :with_first_post do
      transient do
        creator { create :user }
      end

      after(:create) do |topic, evaluator|
        create :post, :first_post, topic: topic, creator: evaluator.creator
      end
    end
  end
end
