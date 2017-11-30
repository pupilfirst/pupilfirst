FactoryBot.define do
  factory :coupon do
    code { rand(36**6).to_s(36) }
    user_extension_days { 15 }
    referrer_extension_days { 10 }
  end
end
