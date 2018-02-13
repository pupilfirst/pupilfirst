class CouponUsage < ApplicationRecord
  belongs_to :coupon
  belongs_to :startup

  scope :redeemed, -> { where.not(redeemed_at: nil) }
end
