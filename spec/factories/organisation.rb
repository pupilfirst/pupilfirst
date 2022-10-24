FactoryBot.define do
  factory :organisation do
    school
    sequence(:name) { |n| "#{Faker::Company.name} #{n}" }
  end
end
