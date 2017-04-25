FactoryGirl.define do
  factory :coupon do
    code { rand(36**6).to_s(36) }
    coupon_type { Coupon::TYPE_DISCOUNT }
    discount_percentage { Coupon::REFERRAL_DISCOUNT }
  end
end
