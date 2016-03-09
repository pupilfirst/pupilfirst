FactoryGirl.define do
  factory :startup do |f|
    f.product_name { Faker::Lorem.words(rand(3) + 1).join ' ' }
    f.product_description { Faker::Lorem.words(12).join(' ').truncate(Startup::MAX_PRODUCT_DESCRIPTION_CHARACTERS) }
    f.name { Faker::Lorem.words(rand(3) + 1).join ' ' }
    f.address { Faker::Lorem.words(6).join(' ') }
    f.website { Faker::Internet.domain_name }
    f.email { Faker::Internet.email }
    f.team_size 3

    after(:build) do |startup|
      startup.founders << create(:founder_with_password, startup: startup, startup_admin: true)
      startup.founders << create(:founder_with_password, startup: startup)
      startup.startup_categories = [create(:startup_category)]
    end

    factory :incubated_startup do
      approval_status Startup::APPROVAL_STATUS_APPROVED
      agreement_first_signed_at { 18.months.ago }
      agreement_last_signed_at { 6.months.ago }
      agreement_ends_at { 6.months.from_now }
    end
  end

  factory :startup_application, class: Startup do |f|
    f.name { Faker::Lorem.characters(20) }
    f.pitch { Faker::Lorem.words(6).join(' ') }
    f.website { Faker::Internet.domain_name }
  end
end
