FactoryGirl.define do
  factory :level_0_startup, class: Startup do
    product_name { ['Red Ramanujan', 'Blue Bell', 'Crimson Copernicus'].sample }

    after(:build) do |startup|
      startup.founders << create(:founder, startup: startup, startup_admin: true)
    end

    level { create :level, :zero }
    maximum_level { level }
  end

  factory :startup do |f|
    sequence(:product_name) { |n| Faker::Lorem.words(rand(3) + 1).push(n).join(' ') }
    f.product_description { Faker::Lorem.words(12).join(' ').truncate(Startup::MAX_PRODUCT_DESCRIPTION_CHARACTERS) }
    f.name { Faker::Lorem.words(rand(3) + 1).join ' ' }
    f.address { Faker::Lorem.words(6).join(' ') }
    f.website { Faker::Internet.domain_name }
    f.email { Faker::Internet.email }
    f.batch
    f.iteration 1
    f.level { create :level, :one }
    f.maximum_level { level }
    f.program_started_on { rand(8.weeks).seconds.ago }

    after(:build) do |startup|
      startup.founders << create(:founder, startup: startup, startup_admin: true)
      startup.founders << create(:founder, startup: startup)
      startup.startup_categories = [create(:startup_category)]
    end

    # TODO: Change this to a trait.
    factory :incubated_startup do
      agreement_signed_at { 18.months.ago }
    end
  end

  factory :startup_application, class: Startup do |f|
    f.name { Faker::Lorem.characters(20) }
    f.pitch { Faker::Lorem.words(6).join(' ') }
    f.website { Faker::Internet.domain_name }
  end
end
