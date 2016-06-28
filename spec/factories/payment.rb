FactoryGirl.define do
  factory :payment do
    batch_application
    instamojo_payment_request_id { SecureRandom.hex }
    instamojo_payment_request_status 'Pending'
    amount 3000
    short_url { Faker::Internet.url }
    long_url { Faker::Internet.url }
  end
end
