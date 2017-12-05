FactoryBot.define do
  factory :founder do
    user { create :user, email: email }
    name { Faker::Name.name }
    email { Faker::Internet.email(name) }
    sequence(:phone) { |n| (9_876_543_210 + n).to_s }
    college
    reference { Founder.valid_references.sample }

    trait(:connected_to_slack) do
      slack_user_id 'SLACK_USER_ID'
      slack_username 'SLACK_USERNAME'
      slack_access_token 'SLACK_ACCESS_TOKEN'
    end
  end
end
