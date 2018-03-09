FactoryBot.define do
  factory :level_0_startup, class: Startup do
    product_name { ['Red Ramanujan', 'Blue Bell', 'Crimson Copernicus'].sample }

    after(:build) do |startup|
      # Add a team lead.
      startup.team_lead = create(:founder, startup: startup)
    end

    level { create :level, :zero }
  end

  factory :startup do
    sequence(:product_name) { |n| Faker::Lorem.words(rand(3) + 1).push(n).join(' ') }
    product_description { Faker::Lorem.words(12).join(' ').truncate(Startup::MAX_PRODUCT_DESCRIPTION_CHARACTERS) }
    name { Faker::Lorem.words(rand(3) + 1).join ' ' }
    address { Faker::Lorem.words(6).join(' ') }
    website { Faker::Internet.domain_name }
    email { Faker::Internet.email }
    level { create :level, :one }
    program_started_on { rand(8.weeks).seconds.ago }

    after(:build) do |startup|
      # Add a team lead.
      startup.team_lead = create(:founder, startup: startup)

      # Add another founder.
      create(:founder, startup: startup)

      startup.startup_categories = [create(:startup_category)]
    end

    trait(:subscription_active) do
      after(:create) do |startup|
        create :payment, :paid, startup: startup
      end
    end
  end
end
