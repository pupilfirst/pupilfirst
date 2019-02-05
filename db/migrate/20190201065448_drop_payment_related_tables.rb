class DropPaymentRelatedTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :coupon_usages
    drop_table :coupons
    drop_table :payments
    remove_column :courses, :sponsored, :boolean
    remove_column :startups, :payment_reference, :string
    remove_column :startups, :billing_address, :text
    remove_column :startups, :billing_state_id, :bigint
    remove_column :startups, :undiscounted_founder_fee, :integer
  end
end
