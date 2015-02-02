FactoryGirl.define do
  factory :startup_job do |j|
    j.startup
    j.title { Faker::Lorem.words(2).join ' ' }
    j.location { Faker::Address.city }
    j.salary_min { rand 100000 }
  end
end
