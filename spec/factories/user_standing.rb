FactoryBot.define do
  factory :user_standing do
    user
    standing
    reason { Faker::Lorem.sentence }
    archived_at { nil }
    archiver { nil }
    creator { create :user }
    created_at { Time.zone.now }
  end
end
