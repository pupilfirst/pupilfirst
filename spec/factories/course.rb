FactoryBot.define do
  factory :course do
    sequence(:name) { |n| [Faker::Lorem.word, n.to_s].join(' ') }
    description { Faker::Lorem.sentence }
    school { School.find_by(name: 'test') || create(:school, :current) }
  end
end
