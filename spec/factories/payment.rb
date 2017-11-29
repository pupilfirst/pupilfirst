FactoryBot.define do
  factory :payment do
    startup
    founder { startup.founders.first }

    after(:create) do |payment|
      payment.update!(founder: payment.startup.team_lead) if payment.founder.blank?
    end

    trait :requested do
      period 1
      amount { Founder::FEE * startup.billing_founders_count }
      instamojo_payment_request_id { SecureRandom.hex }
      instamojo_payment_request_status 'Pending'
      short_url { Faker::Internet.url }
      long_url { Faker::Internet.url }
      billing_start_at 3.days.from_now
      billing_end_at 33.days.from_now
    end

    trait :paid do
      requested
      instamojo_payment_request_status 'Completed'
      instamojo_payment_status 'Credit'
      paid_at 1.day.ago
      billing_start_at 1.day.ago
      billing_end_at 30.days.from_now
      payment_type { Payment::TYPE_ADMISSION }
    end
  end
end
