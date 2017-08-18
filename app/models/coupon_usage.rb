class CouponUsage < ApplicationRecord
  belongs_to :coupon
  belongs_to :startup
  has_one :referrer_startup, through: :coupon

  scope :redeemed, -> { where.not(redeemed_at: nil) }
  scope :referrals, -> { joins(:coupon).where.not(coupons: { referrer_startup_id: nil }) }
end
