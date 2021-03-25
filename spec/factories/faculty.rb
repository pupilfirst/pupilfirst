FactoryBot.define do
  factory :faculty do
    user
    category { Faculty::CATEGORY_VR_COACHES }

    trait :with_coaching_session_link do
      coaching_session_calendly_link { "https://calendly.com/growthtribe" }
    end
  end
end
