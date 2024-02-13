FactoryBot.define do
  factory :submission_comment do
    user
    timeline_event
    comment { Faker::Lorem.sentence }
  end
end
