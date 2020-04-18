FactoryBot.define do
  factory :post do
    body { Faker::Lorem.paragraph }
    topic
    sequence(:post_number)
    creator { create :user }
  end

  trait :first_post do
    post_number { 1 }
  end
end
