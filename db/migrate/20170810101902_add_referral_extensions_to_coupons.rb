class AddReferralExtensionsToCoupons < ActiveRecord::Migration[5.1]
  def change
    add_column :coupons, :user_extension_days, :integer
    add_column :coupons, :referrer_extension_days, :integer
  end
end
