class AddTargetApplicationsCountToBatch < ActiveRecord::Migration
  def change
    add_column :batches, :target_application_count, :integer
  end
end
