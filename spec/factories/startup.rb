FactoryBot.define do
  factory :startup do
    sequence(:product_name) { |n| Faker::Lorem.words(rand(1..3)).push(n).join(' ') }
    name { Faker::Lorem.words(rand(1..3)).join ' ' }
    level { create :level, :one }

    after(:build) do |startup|
      # Add two founder.
      create(:founder, startup: startup)
      create(:founder, startup: startup)
    end
  end
end
