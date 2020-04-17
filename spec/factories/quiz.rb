FactoryBot.define do
  factory :quiz do
    title { Faker::Lorem.words(number: 2) }

    trait :with_question_and_answers do
      after(:create) do |quiz|
        create :quiz_question, :with_answers, quiz: quiz
      end
    end
  end
end
