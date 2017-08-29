require_relative 'helper'

puts 'Seeding coupons'

Coupon.create!(code: '5days', user_extension_days: 5)
Coupon.create!(code: '15days', user_extension_days: 15)
