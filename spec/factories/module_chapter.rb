FactoryGirl.define do
  factory :module_chapter do
    name { Faker::Lorem.words(3).join ' ' }
  end
end
