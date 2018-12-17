FactoryBot.define do
  factory :answer_option do
    quiz_question
    value { Faker::Lorem.word }
    hint { Faker::Lorem.sentence }
  end
end
