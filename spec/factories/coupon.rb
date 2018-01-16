FactoryBot.define do
  factory :coupon do
    code { rand(36**6).to_s(36) }
    discount_percentage { [10, 25, 50, 75].sample }
  end
end
