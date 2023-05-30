FactoryBot.define do
  factory :submission_report do
    reporter { Faker::Name.name }
    trait :queued do
      status { "queued" }
    end

    trait :in_progress do
      status { "in_progress" }
      started_at { 2.minutes.ago }
    end
  end
end
