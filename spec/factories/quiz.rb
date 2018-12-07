FactoryBot.define do
  factory :quiz do
    title { Faker::Lorem.words(2) }
    target { create :target, :auto_verify }
  end
end
