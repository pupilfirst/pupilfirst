class AddTargetApplicationsCountToBatch < ActiveRecord::Migration[4.2]
  def change
    add_column :batches, :target_application_count, :integer
  end
end
