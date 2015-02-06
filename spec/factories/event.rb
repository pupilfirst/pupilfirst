FactoryGirl.define do
  factory :event do
    start_at { Time.now + rand(1000) }
    title { Faker::Lorem.words(3).join(' ') }
    description { Faker::Lorem.paragraph }
    picture { fixture_file_upload(Rails.root.join(*%w[ spec fixtures files example.jpg ]), 'image/jpg') }
    end_at { start_at + rand(1000) }
    location
    author
    posters_name { Faker::Name.name }
    posters_email { Faker::Internet.email }
    sequence(:posters_phone_number) { |n| "#{9876543210 + n}" }
    category { create :event_category }
  end
end
