FactoryBot.define do
  factory :shortened_url do
    sequence(:unique_key) { |n| ('100000'.to_i(36) + n).to_s(36) }
    sequence(:url) { |n| "https://example.com/#{n}" }
  end
end
