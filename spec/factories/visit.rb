FactoryBot.define do
  factory :visit do
    id { SecureRandom.uuid } # because Visit has id of type uuid.
    user { create :user }
  end
end
