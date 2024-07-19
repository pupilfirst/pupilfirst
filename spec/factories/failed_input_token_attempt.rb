FactoryBot.define do
  factory :failed_input_token_attempt do
    authenticatable { create :user }
    purpose { "sign_in" }
  end
end
