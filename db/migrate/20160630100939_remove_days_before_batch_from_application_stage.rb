class RemoveDaysBeforeBatchFromApplicationStage < ActiveRecord::Migration[4.2]
  def change
    remove_column :application_stages, :days_before_batch, :integer
  end
end
