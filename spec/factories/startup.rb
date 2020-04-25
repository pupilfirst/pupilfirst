FactoryBot.define do
  factory :startup do
    sequence(:name) { |n| Faker::Lorem.words(number: rand(2..3)).push(n).join(' ') }
    level { create :level, :one }

    after(:build) do |startup|
      # Add two founder.
      create(:founder, startup: startup)
      create(:founder, startup: startup)
    end
  end

  # Use this factory to get an empty startup.
  factory :team, class: 'Startup' do
    sequence(:name) { |n| Faker::Lorem.words(number: rand(1..3)).push(n).join(' ') }
    level { create :level, :one }
  end
end
