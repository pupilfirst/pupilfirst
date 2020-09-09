FactoryBot.define do
  factory :text_version do
    value { Faker::Lorem.sentence }

    trait :post do
      versionable { create :post }
    end
  end
end
