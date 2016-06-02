FactoryGirl.define do
  factory :application_stage do
    sequence(:name) { |n| "#{Faker::Lorem.word} #{n}" }
    sequence(:number) { |n| n + 1 }
    days_before_batch { [60, 50, 40, 30, 20, 10, 1].sample }
  end
end
