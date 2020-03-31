FactoryBot.define do
  factory :bounce_report do
    email { Faker::Internet.email }
    bounce_type { %w[HardBounce SpamComplaint].sample }
  end
end
