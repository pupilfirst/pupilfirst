class AddIndexToFounderId < ActiveRecord::Migration
  def change
    add_index :platform_feedback, :founder_id
  end
end
