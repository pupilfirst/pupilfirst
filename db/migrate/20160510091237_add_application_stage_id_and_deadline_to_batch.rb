class AddApplicationStageIdAndDeadlineToBatch < ActiveRecord::Migration
  def change
    add_reference :batches, :application_stage, index: true
    add_column :batches, :application_stage_deadline, :timestamp
  end
end
