# Todo: To be updated
FactoryBot.define do
  factory :team_with_students do
    sequence(:name) do |n|
      Faker::Lorem.words(number: rand(2..3)).push(n).join(' ')
    end
    level { create :level, :one }

    after(:build) do |startup|
      # Add two founder.
      create(:founder, startup: startup)
      create(:founder, startup: startup)
    end
  end

  # Use this factory to get an empty startup.
  factory :team, class: 'Startup' do
    sequence(:name) do |n|
      Faker::Lorem.words(number: rand(1..3)).push(n).join(' ')
    end
    level { create :level, :one }
  end
end
