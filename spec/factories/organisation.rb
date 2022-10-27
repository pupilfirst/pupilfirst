FactoryBot.define do
  factory :organisation do
    school { School.find_by(name: 'test') || create(:school, :current) }
    sequence(:name) { |n| "#{Faker::Company.name} #{n}" }
  end
end
