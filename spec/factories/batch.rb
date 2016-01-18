FactoryGirl.define do
  factory :batch do
    name { Faker::Lorem.word }
    description { Faker::Lorem.words(10).join ' ' }
    start_date { 1.month.ago }
    end_date { 5.months.from_now }
    batch_number 1
  end
end
