FactoryBot.define do
  factory :authentication_token do
    authenticatable { create :user }
    token { "123456" }
    token_type { "input_token" }
    purpose { "sign_in" }
    expires_at { 15.minutes.from_now }

    trait(:url_token) do
      token_type { "url_token" }
      purpose { "sign_in" }
      token { SecureRandom.urlsafe_base64 }
    end

    trait(:api_token) do
      token_type { "hashed_token" }
      purpose { "use_api" }
      token { Digest::SHA2.base64digest(SecureRandom.urlsafe_base64) }
      expires_at { nil }
    end
  end
end
