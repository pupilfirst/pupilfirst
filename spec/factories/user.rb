FactoryBot.define do
  factory :user do
    email { Faker::Internet.email(name: name) }
    name { Faker::Name.name }
    school { School.find_by(name: 'test') || create(:school, :current) }
    title { Faker::Lorem.words(number: 3).join(' ') }
  end
end
