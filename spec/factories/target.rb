FactoryGirl.define do
  factory :target do
    role { Target.valid_roles.sample }
    assigner { create :faculty }
    assignee { role == 'founder' ? (create :founder_with_out_password) : (create :startup) }
    status { 'pending' }
    title { Faker::Lorem.words(6).join ' ' }
    description { Faker::Lorem.words(200).join ' ' }
    resource_url { Faker::Internet.url }
  end
end
