FactoryBot.define do
  factory :course_category do
    name { Faker::Lorem.word }
    school
  end
end
