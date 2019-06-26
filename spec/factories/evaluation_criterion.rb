FactoryBot.define do
  factory :evaluation_criterion do
    sequence(:name) { |i| (Faker::Lorem.words(2) + [i.to_s]).join(' ') }
    description { Faker::Lorem.sentence }
  end
end
