class CreateCoupons < ActiveRecord::Migration[5.0]
  def change
    create_table :coupons do |t|
      t.string :code
      t.string :coupon_type
      t.integer :discount_percentage
      t.integer :redeem_limit, default: 0
      t.datetime :expires_at

      t.timestamps
    end
  end
end
