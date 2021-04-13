FactoryBot.define do
  factory :domain do
    fqdn { Faker::Internet.domain_name }
    school

    trait(:primary) { primary { true } }
  end
end
