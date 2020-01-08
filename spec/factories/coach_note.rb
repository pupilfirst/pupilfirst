FactoryBot.define do
  factory :coach_note do
    note { Faker::Lorem.sentence }
  end
end
