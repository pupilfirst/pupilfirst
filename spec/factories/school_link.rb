FactoryBot.define do
  factory :school_link do
    sequence(:title) { |n| "#{Faker::Lorem.word} #{n}" }
    url { |school_link| Faker::Internet.url(host: school_link.title) }
    school

    trait(:header) do
      kind { SchoolLink::KIND_HEADER }
    end

    trait(:social) do
      kind { SchoolLink::KIND_SOCIAL }
    end

    trait(:footer) do
      kind { SchoolLink::KIND_FOOTER }
    end
  end
end
