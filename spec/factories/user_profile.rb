FactoryBot.define do
  factory :user_profile do
    user
    school
    name { Faker::Name.name }
    sequence(:phone) { |n| (9_876_543_210 + n).to_s }
  end
end
