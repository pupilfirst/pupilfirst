FactoryGirl.define do
  factory :answer_option do
    value { Faker::Lorem.word }
  end
end
