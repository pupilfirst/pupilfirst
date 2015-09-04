FactoryGirl.define do
  factory :category do
    name { Faker::Lorem.words(2).join(' ') }

    factory :user_category do
      category_type :user
    end

    factory :startup_category do
      category_type :startup
    end
  end
end
