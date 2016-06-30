class AddNextStageStartsOnToBatch < ActiveRecord::Migration
  def change
    add_column :batches, :next_stage_starts_on, :date
  end
end
