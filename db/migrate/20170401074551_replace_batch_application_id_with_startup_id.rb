class ReplaceBatchApplicationIdWithStartupId < ActiveRecord::Migration[5.0]
  def change
    rename_column :coupon_usages, :batch_application_id, :startup_id
  end
end
