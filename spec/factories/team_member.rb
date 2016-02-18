FactoryGirl.define do
  factory :team_member do
    name { Faker::Name.name }
    email { Faker::Internet.email(name) }
    roles { Founder.valid_roles.sample(2) }
    startup
  end
end
