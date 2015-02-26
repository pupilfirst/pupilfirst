FactoryGirl.define do
  factory :startup_job do |j|
    j.startup
    j.title { Faker::Lorem.words(2).join ' ' }
    j.location { Faker::Address.city }
    j.salary_min { rand 100000 }
    j.contact_name { Faker::Name.name }
    j.description { Faker::Lorem.characters(499) }
    sequence(:contact_number) { |n| "#{9876543210 + n}" }
  end
end
