class RenameBatchStageToRoundStage < ActiveRecord::Migration[5.0]
  def change
    rename_table :batch_stages, :round_stages
    remove_reference :round_stages, :batch
    add_reference :round_stages, :application_round, foreign_key: true
  end
end
