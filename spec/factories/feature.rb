FactoryBot.define do
  factory :feature do
    key { 'test_feature' }
    value { { active: false }.to_json }
  end
end
