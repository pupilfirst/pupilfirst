FactoryGirl.define do
  factory :application_submission_url do
    name { ['Live Website', 'Application Binary'].sample }
    url { Faker::Internet.url }
    application_submission
  end
end
