class RemoveReferralRelatedColumnsFromCoupon < ActiveRecord::Migration[5.1]
  def change
    remove_column :coupons, :referrer_startup_id, :integer
    remove_column :coupons, :user_extension_days, :integer
    remove_column :coupons, :referrer_extension_days, :integer
  end
end
