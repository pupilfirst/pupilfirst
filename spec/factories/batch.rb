FactoryGirl.define do
  factory :batch do
    theme { Faker::Lorem.word }
    sequence(:batch_number) { |n| n + 1 }
    description { Faker::Lorem.words(10).join ' ' }
    start_date { 1.month.ago }
    end_date { 5.months.from_now }
  end
end
