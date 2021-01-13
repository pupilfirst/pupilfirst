class AddApplicationStageIdAndDeadlineToBatch < ActiveRecord::Migration[4.2]
  def change
    add_reference :batches, :application_stage, index: true
    add_column :batches, :application_stage_deadline, :timestamp
  end
end
