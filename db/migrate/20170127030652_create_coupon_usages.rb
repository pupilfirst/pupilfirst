class CreateCouponUsages < ActiveRecord::Migration[5.0]
  def change
    create_table :coupon_usages do |t|
      t.integer :coupon_id
      t.integer :batch_application_id
      t.datetime :redeemed_at
    end
    add_index :coupon_usages, :coupon_id
    add_index :coupon_usages, :batch_application_id
  end
end
