FactoryBot.define do
  factory :user do
    email { Faker::Internet.email(name: name) }
    name { Faker::Name.name }
    school { School.find_by(name: 'test') || create(:school, :current) }
    title { Faker::Lorem.words(number: 3).join(' ') }
    time_zone { ENV['SPEC_USER_TIME_ZONE'] || 'Asia/Kolkata' }
  end
end
