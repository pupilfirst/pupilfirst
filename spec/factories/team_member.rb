FactoryGirl.define do
  factory :team_member do
    name { Faker::Name.name }
    email { Faker::Internet.email(name) }
    roles { Founder.valid_roles.sample([1, 2].sample) }
    startup
  end
end
