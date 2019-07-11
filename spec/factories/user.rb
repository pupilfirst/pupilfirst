FactoryBot.define do
  factory :user do
    email { Faker::Internet.email(name) }
    name { Faker::Name.name }
    school_id { School.find_by(name: 'test')&.id || create(:school, :current).id }
    title { Faker::Lorem.words(3).join(' ') }
  end
end
