FactoryBot.define do
  factory :course do
    name { Faker::Lorem.word }
    school { School.find_by(name: 'default') || create(:school, name: 'default') }
  end
end
