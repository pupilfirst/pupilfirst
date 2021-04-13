FactoryBot.define do
  factory :school_link do
    sequence(:title) { |n| "#{Faker::Lorem.word} #{n}" }
    url { |school_link| Faker::Internet.url(host: school_link.title) }
    school

    trait(:header) { kind { SchoolLink::KIND_HEADER } }

    trait(:social) { kind { SchoolLink::KIND_SOCIAL } }

    trait(:footer) { kind { SchoolLink::KIND_FOOTER } }
  end
end
