FactoryBot.define do
  factory :submission_report do
    description { Faker::Lorem.sentence }
    trait :pending do
      status { 'pending' }
    end

    trait :success do
      status { 'success' }
    end

    trait :error do
      status { 'error' }
    end

    trait :failure do
      status { 'failure' }
    end
  end
end
