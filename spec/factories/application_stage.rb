FactoryGirl.define do
  factory :application_stage do
    sequence(:name) { |n| "#{Faker::Lorem.word} #{n}" }
    sequence(:number) { |n| n + 1 }
  end
end
