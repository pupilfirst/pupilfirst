FactoryGirl.define do
  factory :mentor do
    user { create :user_with_out_password }
    availability(days: Date::DAYNAMES, time: { after: 8, before: 20 })
    company_level Startup::PRODUCT_PROGRESS_IDEA
    verified_at { Time.now }
    company { Faker::Company.name }
  end
end
