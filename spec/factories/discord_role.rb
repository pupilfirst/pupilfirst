FactoryBot.define do
  factory :discord_role do
    name { Faker::Name.unique.name }
    discord_id { Faker::Number.number(digits: 19) }
    position { Faker::Number.digit }
    color_hex { Faker::Color.hex_color }
    data do
      { id: discord_id, icon: nil, name: name, color: 0, position: position }
    end
  end
end
