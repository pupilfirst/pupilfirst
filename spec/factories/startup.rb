FactoryGirl.define do
  factory :startup do |f|
    f.product_name { Faker::Lorem.words(rand(3) + 1).join ' ' }
    f.product_description { Faker::Lorem.words(12).join(' ').truncate(Startup::MAX_PRODUCT_DESCRIPTION_CHARACTERS) }
    f.name { Faker::Lorem.words(rand(3) + 1).join ' ' }
    f.address { Faker::Lorem.words(6).join(' ') }
    f.website { Faker::Internet.domain_name }
    f.email { Faker::Internet.email }

    after(:build) do |startup|
      startup.founders << create(:founder_with_password, startup: startup, startup_admin: true)
      startup.founders << create(:founder_with_password, startup: startup)
      startup.startup_categories = [create(:startup_category)]
    end

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
