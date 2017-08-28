require_relative 'helper'

puts 'Seeding coupons'

Coupon.create!(code: '5days', coupon_type: Coupon::TYPE_REFERRAL, user_extension_days: 5)
Coupon.create!(code: '15days', coupon_type: Coupon::TYPE_REFERRAL, user_extension_days: 15)
