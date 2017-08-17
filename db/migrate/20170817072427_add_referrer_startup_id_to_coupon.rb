class AddReferrerStartupIdToCoupon < ActiveRecord::Migration[5.1]
  def change
    add_column :coupons, :referrer_startup_id, :integer
  end
end
