FactoryBot.define do
  factory :post do
    body { Faker::Lorem.paragraph }
    sequence(:post_number) { |n| n }
    creator { create :user }

    trait :first_post do
      post_number { 1 }
    end

    trait :archived do
      archived_at { Time.zone.now }
    end
  end
end
