require_relative 'helper'

after 'development:founders' do
  founder = Founder.find_by email: 'someone@sv.co'

  PlatformFeedback.create!(
    founder: founder,
    feedback_type: PlatformFeedback.types_of_feedback.sample,
    description: Faker::Lorem.paragraph
  )
end
