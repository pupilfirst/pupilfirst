FactoryBot.define do
  factory :public_slack_message do
    channel { 'general' }
    body { Faker::Lorem.words(number: 10).join ' ' }
    slack_username { Faker::Lorem.word }
  end
end
