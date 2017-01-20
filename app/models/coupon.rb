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
end
