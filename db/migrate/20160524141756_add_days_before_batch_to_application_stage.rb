class AddDaysBeforeBatchToApplicationStage < ActiveRecord::Migration[4.2]
  def change
    add_column :application_stages, :days_before_batch, :integer
  end
end
