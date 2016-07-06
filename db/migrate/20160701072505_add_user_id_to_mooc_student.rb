class AddUserIdToMoocStudent < ActiveRecord::Migration
  def change
    add_column :mooc_students, :user_id, :integer
  end
end
