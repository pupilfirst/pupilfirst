require_relative 'helper'

after 'development:startups' do
  puts 'Seeding coupons (idempotent)'
  super_heroes = Startup.find_by(product_name: 'SuperHeroes')
  super_product = Startup.find_by(product_name: 'Super Product')

  Coupon.where(code: 'avengers').first_or_create!(
    user_extension_days: 15,
    referrer_startup: super_heroes,
    referrer_extension_days: 10
  )

  Coupon.where(code: 'product').first_or_create!(
    user_extension_days: 15,
    referrer_startup: super_product,
    referrer_extension_days: 10
  )

  Coupon.where(code: 'vanilla').first_or_create!(user_extension_days: 10)
end
