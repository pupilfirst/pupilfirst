FactoryBot.define do
  factory :webhook_endpoint do
    course
    active { true }
    webhook_url { Faker::Internet.url }
    events { WebhookDelivery.events.values }
  end
end
