FactoryBot.define do
  factory :answer_option do
    quiz_question
    value { Faker::Lorem.words(3).join ' ' }
    hint { Faker::Lorem.sentence }
  end
end
