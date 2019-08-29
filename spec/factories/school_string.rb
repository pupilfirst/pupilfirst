FactoryBot.define do
  factory :school_string do
    sequence(:value) { |n| "#{Faker::Lorem.word} #{n}" }
    school { School.find_by(name: 'test') || create(:school, :current) }

    trait(:privacy_policy) do
      key { SchoolString::PrivacyPolicy.key }
    end

    trait(:terms_of_use) do
      key { SchoolString::TermsOfUse.key }
    end
  end
end
