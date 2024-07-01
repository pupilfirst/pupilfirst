FactoryBot.define do
  factory :school do
    name { Faker::Lorem.words(number: 2).join(" ") }

    trait(:current) do
      name { "test" }

      after(:create) do |school|
        Domain.where(school: school, fqdn: "test.host").first_or_create!(
          primary: true
        )
      end
    end

    after(:build) do |school|
      school.icon_on_light_bg.attach(
        io:
          Rails
            .root
            .join("spec/support/uploads/files/icon_pupilfirst.png")
            .open,
        filename: "icon_pupilfirst.png",
        content_type: "image/png"
      )
    end
  end
end
