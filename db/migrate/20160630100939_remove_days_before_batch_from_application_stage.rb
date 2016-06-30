class RemoveDaysBeforeBatchFromApplicationStage < ActiveRecord::Migration
  def change
    remove_column :application_stages, :days_before_batch, :integer
  end
end
