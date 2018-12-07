FactoryBot.define do
  factory :quiz_question do
    question { Faker::Lorem.sentence }
    description { Faker::Lorem.sentence }
    quiz

    trait :with_answers do
      answer_options { create_list(:answer_options, 4) }
      correct_answer { answer_options.first }
    end
  end
end
