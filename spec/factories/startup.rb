FactoryBot.define do
  factory :startup do
    sequence(:name) { |n| Faker::Lorem.words(rand(1..3)).push(n).join(' ') }
    level { create :level, :one }

    after(:build) do |startup|
      # Add two founder.
      create(:founder, startup: startup)
      create(:founder, startup: startup)
    end
  end
end
