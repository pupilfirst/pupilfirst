class CouponUsage < ApplicationRecord
  belongs_to :coupon
  belongs_to :billing_plan
end
