FactoryBot.define do
  factory :standing do
    name { Faker::Lorem.words(number: 2).join(" ") }
    color { Faker::Color.hex_color }
    description { Faker::Lorem.sentences(number: 1) }
    school { School.find_by(name: "test") || create(:school, :current) }
    default { false }
  end
end
