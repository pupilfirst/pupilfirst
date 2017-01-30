class CouponUsage < ApplicationRecord
  belongs_to :coupon
  belongs_to :batch_application

  validates :coupon, presence: true
  validates :batch_application, presence: true

  scope :redeemed, -> { where.not(redeemed_at: nil) }
  scope :referrals, -> { joins(:coupon).where.not(coupons: { referrer_id: nil }) }
end
