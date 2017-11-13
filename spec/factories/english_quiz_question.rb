FactoryGirl.define do
  factory :english_quiz_question do
    question { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'uploads', 'resources', 'pdf-thumbnail.png')) }
    explanation { Faker::Lorem.words(12).join ' ' }
    answer_options { build_list :answer_option, 4 }

    # Mark a random answer as the correct one.
    after(:create) do |english_quiz_question|
      english_quiz_question.answer_options.sample.update!(correct_answer: true)
    end
  end
end
