class AddNextStageStartsOnToBatch < ActiveRecord::Migration[4.2]
  def change
    add_column :batches, :next_stage_starts_on, :date
  end
end
