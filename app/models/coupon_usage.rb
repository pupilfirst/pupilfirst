class CouponUsage < ApplicationRecord
  belongs_to :coupon
  belongs_to :batch_application

  validates :coupon, presence: true
  validates :batch_application, presence: true
end
