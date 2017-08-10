class Coupon < ApplicationRecord
  has_many :coupon_usages
  has_many :startups, through: :coupon_usages
  belongs_to :referrer, class_name: 'Founder', optional: true

  scope :referral, -> { where.not(referrer_id: nil) }

  # TODO: Now that it's all referral coupons, probably scrap coupon_type entirely.
  TYPE_DISCOUNT = -'Discount'
  TYPE_MSP = -'Microsoft Student Partner'
  TYPE_REFERRAL = -'Referral'

  REFERRAL_DISCOUNT = 25
  REFERRAL_LIMIT = 0

  def self.valid_coupon_types
    [TYPE_DISCOUNT, TYPE_MSP, TYPE_REFERRAL]
  end

  validates :code, uniqueness: true, presence: true, length: { in: 4..10 }
  validates :coupon_type, inclusion: { in: valid_coupon_types }
  validates :referrer_id, uniqueness: true, allow_nil: true

  def still_valid?
    (expires_at.blank? || expires_at.future?) && redeems_left?
  end

  def redeems_left?
    return true if redeem_limit.zero?

    redeem_count = coupon_usages.redeemed.count
    redeem_count < redeem_limit
  end

  def mark_redeemed!(startup)
    coupon_usage = CouponUsage.where(coupon: self, startup: startup).last
    coupon_usage.update!(redeemed_at: Time.now)
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
