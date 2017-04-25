FactoryGirl.define do
  factory :payment do
    startup
    founder { startup.admin }
    instamojo_payment_request_id { SecureRandom.hex }
    instamojo_payment_request_status 'Pending'
    amount 3000
    short_url { Faker::Internet.url }
    long_url { Faker::Internet.url }

    after(:create) do |payment|
      payment.update!(founder: payment.startup.admin) if payment.founder.blank?
    end

    trait :paid do
      instamojo_payment_request_status 'Completed'
      instamojo_payment_status 'Credit'
      paid_at Time.now
    end
  end
end
