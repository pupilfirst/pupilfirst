FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
  end
end
