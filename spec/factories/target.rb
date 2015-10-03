FactoryGirl.define do
  factory :target do
    role { Target.valid_roles.sample }
    timeline_event_type
    assigner { create :admin_user }
    startup
    title { Faker::Lorem.words(6).join ' ' }
    short_description { Faker::Lorem.words(12).join ' ' }
    resource_url { Faker::Internet.url }
  end
end
