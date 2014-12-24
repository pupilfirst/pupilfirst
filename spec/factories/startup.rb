FactoryGirl.define do
  factory :startup do |f|
    f.name { Faker::Lorem.characters(20) }
    f.logo { fixture_file_upload(Rails.root.join(*%w[ spec fixtures files example.jpg ]), 'image/jpg') }
    f.pitch { Faker::Lorem.words(6).join(' ') }
    f.address { Faker::Lorem.words(6).join(' ') }
    f.about { Faker::Lorem.paragraph(7) }
    f.website { Faker::Internet.domain_name }
    f.email { Faker::Internet.email }
    f.phone { Faker::PhoneNumber.cell_phone }
    f.incubation_location Startup::INCUBATION_LOCATION_KOCHI
    # f.founders {[create(:founder), create(:founder)]}
    # f.category_ids {[create(:startup_category).id]}
    after(:build) do |startup|
      startup.founders << create(:founder, startup: startup)
      startup.founders << create(:founder, startup: startup)
      startup.categories = [create(:startup_category)]
    end
  end

  factory :startup_application, class: Startup do |f|
    f.name { Faker::Lorem.characters(20) }
    f.pitch { Faker::Lorem.words(6).join(' ') }
    f.website { Faker::Internet.domain_name }
    f.phone { Faker::PhoneNumber.cell_phone }
  end

  factory :incorporation, class: Startup do |f|
    f.dsc 'dsc'
    f.company_names [{name: 'company1', description: 'desc'}]
    f.authorized_capital 'authorized_capital'
    f.share_holding_pattern 'share_holding_pattern'
    f.moa 'moa'
    f.police_station 'police_station'
  end
end