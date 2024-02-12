FactoryBot.define do
  factory :standing do
    sequence(:name) { |number| "#{Faker::Lorem.word} #{number}" }
    color { Faker::Color.hex_color }
    description { Faker::Lorem.sentences(number: 1) }
    school { School.find_by(name: "test") || create(:school, :current) }
    default { false }
  end
end
