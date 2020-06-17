FactoryBot.define do
  factory :user do
    email { Faker::Internet.email(name: name) }
    sequence(:name) { |n| "#{Faker::Name.name} #{n}" }
    school { School.find_by(name: 'test') || create(:school, :current) }
    title { Faker::Lorem.words(number: 3).join(' ') }
    time_zone { ENV['SPEC_USER_TIME_ZONE'] || 'Asia/Kolkata' }
  end
end
