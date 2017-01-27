class RemoveCouponIdFromBatchApplication < ActiveRecord::Migration[5.0]
  def change
    remove_column :batch_applications, :coupon_id, :integer
  end
end
