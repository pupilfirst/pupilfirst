FactoryBot.define do
  factory :school_string do
    sequence(:value) { |n| "#{Faker::Lorem.word} #{n}" }
    school { School.find_by(name: 'test') || create(:school, :current) }

    trait(:privacy_policy) do
      key { SchoolString::PrivacyPolicy.key }
    end

    trait(:terms_and_conditions) do
      key { SchoolString::TermsAndConditions.key }
    end
  end
end
