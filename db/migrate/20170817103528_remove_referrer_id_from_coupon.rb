class RemoveReferrerIdFromCoupon < ActiveRecord::Migration[5.1]
  def change
    remove_column :coupons, :referrer_id, :integer
  end
end
