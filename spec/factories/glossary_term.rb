FactoryGirl.define do
  factory :glossary_term do
    term { Faker::Lorem.words(2).join(' ') }
    definition { Faker::Lorem.sentence }
  end
end
