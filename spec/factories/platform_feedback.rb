FactoryBot.define do
  factory :platform_feedback do
    founder { create :founder }
    description { Faker::Lorem.sentence }
    feedback_type { PlatformFeedback.types_of_feedback.sample }
  end
end
