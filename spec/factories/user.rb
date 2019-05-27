FactoryBot.define do
  factory :user, aliases: [:creator] do
    email { Faker::Internet.email }
  end
end
