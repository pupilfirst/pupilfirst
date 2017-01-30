class AddRewardColumnsToCouponUsage < ActiveRecord::Migration[5.0]
  def change
    add_column :coupon_usages, :rewarded_at, :datetime
    add_column :coupon_usages, :notes, :text
  end
end
