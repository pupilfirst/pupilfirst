require_relative 'helper'

after 'development:startups' do
  puts 'Seeding coupons (idempotent)'

  Coupon.where(code: 'halfoff').first_or_create!(discount_percentage: 50, instructions: 'This is a test coupon, usable in the development environment.')
end
