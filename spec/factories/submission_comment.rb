FactoryBot.define do
  factory :submission_comment do
    user
    submission { create(:timeline_event) }
    comment { Faker::Lorem.sentence }
  end
end
