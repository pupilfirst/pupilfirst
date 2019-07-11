FactoryBot.define do
  factory :user do
    user { create :user, email: Faker::Internet.email(name) }
    name { Faker::Name.name }
    school { School.find_by(name: 'test') || create(:school, :current) }
    title { Faker::Lorem.words(3).join(' ') }
  end
end
