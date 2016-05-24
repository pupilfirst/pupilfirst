class AddDaysBeforeBatchToApplicationStage < ActiveRecord::Migration
  def change
    add_column :application_stages, :days_before_batch, :integer
  end
end
