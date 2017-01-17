FactoryGirl.define do
  factory :payment do
    batch_application
    batch_applicant { batch_application.team_lead }
    instamojo_payment_request_id { SecureRandom.hex }
    instamojo_payment_request_status 'Pending'
    amount 3000
    short_url { Faker::Internet.url }
    long_url { Faker::Internet.url }

    after(:create) do |payment|
      payment.update!(batch_applicant: payment.batch_application.team_lead)
    end

    trait :paid do
      instamojo_payment_request_status 'Completed'
      instamojo_payment_status 'Credit'
      paid_at Time.now

      after(:create) do |payment|
        payment.batch_application.perform_post_payment_tasks!
      end
    end
  end
end
