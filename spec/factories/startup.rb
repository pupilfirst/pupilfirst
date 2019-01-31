FactoryBot.define do
  factory :startup do
    sequence(:product_name) { |n| Faker::Lorem.words(rand(1..3)).push(n).join(' ') }
    product_description { Faker::Lorem.words(12).join(' ').truncate(Startup::MAX_PRODUCT_DESCRIPTION_CHARACTERS) }
    name { Faker::Lorem.words(rand(1..3)).join ' ' }
    address { Faker::Lorem.words(6).join(' ') }
    website { Faker::Internet.domain_name }
    level { create :level, :one }
    program_started_on { rand(8.weeks).seconds.ago }

    after(:build) do |startup|
      # Add two founder.
      create(:founder, startup: startup)
      create(:founder, startup: startup)
    end
  end
end
