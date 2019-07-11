FactoryBot.define do
  factory :founder do
    user
    college
    startup
    dashboard_toured { true }

    trait(:connected_to_slack) do
      slack_user_id { 'SLACK_USER_ID' }
      slack_username { 'SLACK_USERNAME' }
      slack_access_token { 'SLACK_ACCESS_TOKEN' }
    end

    after(:create) do |founder|
      UserProfile.where(user: founder.user, school: founder.school).first_or_create!(
        name: founder.user.name
      )
    end
  end
end
