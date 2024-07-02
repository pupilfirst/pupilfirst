FactoryBot.define do
  factory :school do
    name { Faker::Lorem.words(number: 2).join(" ") }

    trait(:current) do
      name { "test" }

      after(:create) do |school|
        Domain.where(school: school, fqdn: "test.host").first_or_create!(
          primary: true,
        )
      end
    end

    trait(:beckn_enabled) do
      beckn_enabled { true }
      after(:create) do |school|
        # Ensure the school has a domain
        school.domains.create!(fqdn: "#{school.id}.host", primary: true)
        # Ensure the school has a school string for email address
        school.school_strings.create!(
          key: SchoolString::EmailAddress.key,
          value: Faker::Internet.email,
        )
        # Ensure the school has a school string for description
        school.school_strings.create!(
          key: SchoolString::Description.key,
          value: Faker::Lorem.sentence,
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
