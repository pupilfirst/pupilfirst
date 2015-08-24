FactoryGirl.define do
  factory :startup do |f|
    f.name { Faker::Lorem.words(rand(3) + 1).join ' ' }
    f.logo { fixture_file_upload(Rails.root.join(*%w[ spec fixtures files example.jpg ]), 'image/jpg') }
    f.pitch { Faker::Lorem.words(6).join(' ') }
    f.address { Faker::Lorem.words(6).join(' ') }
    f.about { Faker::Lorem.words(12).join(' ').truncate(Startup::MAX_ABOUT_CHARACTERS) }
    f.website { Faker::Internet.domain_name }
    f.email { Faker::Internet.email }
    f.incubation_location Startup::INCUBATION_LOCATION_KOCHI
    # f.founders {[create(:founder), create(:founder)]}
    # f.category_ids {[create(:startup_category).id]}
    after(:build) do |startup|
      startup.founders << create(:founder, startup: startup, startup_admin: true)
      startup.founders << create(:founder, startup: startup)
      startup.categories = [create(:startup_category)]
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
