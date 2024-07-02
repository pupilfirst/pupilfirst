FactoryBot.define do
  factory :discord_server_role_response, class: Hash do
    initialize_with { attributes.stringify_keys }

    id { "#{Faker::Number.number(digits: 24)}" }
    icon { nil }
    name { Faker::Name.name }
    color { 0 }
    flags { 0 }
    hoist { false }
    position { 1 }
    description { nil }
    mentionable { false }
    permissions { "8" }
    unicode_emoji { nil }
  end
end
