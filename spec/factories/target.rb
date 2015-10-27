FactoryGirl.define do
  factory :target do
    role { Target.valid_roles.sample }
    assigner { create :faculty }
    startup
    status { 'pending' }
    title { Faker::Lorem.words(6).join ' ' }
    short_description { Faker::Lorem.words(12).join ' ' }
    resource_url { Faker::Internet.url }
  end
end
