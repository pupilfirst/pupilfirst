FactoryBot.define do
  factory :domain do
    fqdn { Faker::Internet.domain_name }
    school

    trait(:primary) do
      primary { true }
    end
  end
end
