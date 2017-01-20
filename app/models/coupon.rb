class Coupon < ApplicationRecord
  has_many :batch_applications

  TYPE_DISCOUNT = -'Discount'
  TYPE_MSP = -'Microsoft Student Partner'

  def self.valid_coupon_types
    [TYPE_DISCOUNT, TYPE_MSP]
  end

  validates :code, uniqueness: true, presence: true
  validates :coupon_type, inclusion: { in: valid_coupon_types }
  validates :discount_percentage, presence: true, inclusion: { in: 0..100, message: 'must be between 0 and 100' }

  def still_valid?
    (expires_at.blank? || expires_at.future?) && redeems_left?
  end

  def redeems_left?
    return true if redeem_limit.zero?

    redeem_count = BatchApplication.where(coupon: self).count
    redeem_count < redeem_limit
  end
end
