class RenameEvaluatedAtToPassedAt < ActiveRecord::Migration[5.2]
  def change
    rename_column :timeline_events, :evaluated_at, :passed_at
  end
end
