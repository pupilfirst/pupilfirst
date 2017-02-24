class AddLevelToTarget < ActiveRecord::Migration[5.0]
  def change
    add_reference :targets, :level, index: true
  end
end
