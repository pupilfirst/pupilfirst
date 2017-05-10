require_relative 'helper'

puts 'Seeding coupons'

Coupon.create!(code: 'iammsp', coupon_type: Coupon::TYPE_MSP, discount_percentage: 100)
Coupon.create!(code: 'halfoff', coupon_type: Coupon::TYPE_DISCOUNT, discount_percentage: 50)
Coupon.create!(code: 'fulloff', coupon_type: Coupon::TYPE_DISCOUNT, discount_percentage: 100)
