FactoryBot.define do
  factory :community do
    name { Faker::Lorem.words(number: 2).join(' ') }
    school

    trait :target_linkable do
      target_linkable { true }
    end
  end
end
