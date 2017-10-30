FactoryGirl.define do
  factory :english_quiz_question do
    question { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'support', 'uploads', 'resources', 'pdf-thumbnail.png')) }
    explanation { Faker::Lorem.words(12).join ' ' }

    # Add four answer options ...
    after(:create) do |english_quiz_question|
      create_list :answer_option, 4, quiz_question: english_quiz_question
      # ... and mark a random one as the correct answer.
      english_quiz_question.answer_options.sample.update!(correct_answer: true)
    end
  end
end
