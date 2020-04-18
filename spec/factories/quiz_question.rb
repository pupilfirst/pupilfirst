FactoryBot.define do
  factory :quiz_question do
    question { Faker::Lorem.sentence }
    description { Faker::Lorem.sentence }
    quiz

    trait :with_answers do
      after(:create) do |quiz_question|
        answer_options = create_list(:answer_option, 4, quiz_question: quiz_question)
        quiz_question.update!(correct_answer: answer_options.first)
      end
    end
  end
end
