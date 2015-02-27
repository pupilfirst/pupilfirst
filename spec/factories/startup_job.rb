FactoryGirl.define do
  factory :startup_job do |j|
    j.startup
    j.title { Faker::Lorem.words(2).join ' ' }
    j.location { Faker::Address.city }
    j.salary_min { rand 100000 }
    j.contact_name { Faker::Name.name }
    j.contact_email { Faker::Internet.email }
    j.description { Faker::Lorem.characters(499) }
  end
end
