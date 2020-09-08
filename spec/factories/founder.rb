FactoryBot.define do
  factory :founder do
    user
    startup
    dashboard_toured { true }

    trait(:connected_to_slack) do
      slack_user_id { 'SLACK_USER_ID' }
      slack_username { 'SLACK_USERNAME' }
      slack_access_token { 'SLACK_ACCESS_TOKEN' }
    end
  end

  factory :student, class: 'Founder' do
    user
    startup { create :team }
  end
end
