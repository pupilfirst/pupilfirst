class Coupon < ApplicationRecord
  has_many :coupon_usages, dependent: :restrict_with_exception

  validates :code, uniqueness: true, presence: true, length: { in: 4..10 }
  validates :discount_percentage, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 100 }

  def still_valid?
    (expires_at.blank? || expires_at.future?) && redeems_left?
  end

  def redeems_left?
    return true if redeem_limit.zero?

    redeem_count = coupon_usages.redeemed.count
    redeem_count < redeem_limit
  end

  alias_attribute :name, :code

  # ransacker filter for admin index page
  ransacker :validity, formatter: proc { |v|
    coupons = if v == 'Valid'
      Coupon.all.select(&:still_valid?)
    elsif v == 'Invalid'
      Coupon.all.reject(&:still_valid?)
    else
      Coupon.all
    end

    coupons.present? ? coupons.map(&:id) : nil
  } do |parent|
    parent.table[:id]
  end
end
