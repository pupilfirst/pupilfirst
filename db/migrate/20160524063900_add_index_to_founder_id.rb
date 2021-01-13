class AddIndexToFounderId < ActiveRecord::Migration[4.2]
  def change
    add_index :platform_feedback, :founder_id
  end
end
