class RemoveStageInfoFromBatch < ActiveRecord::Migration
  def change
    remove_reference :batches, :application_stage
    remove_column :batches, :application_stage_deadline, :datetime
    remove_column :batches, :next_stage_starts_on, :date
  end
end
