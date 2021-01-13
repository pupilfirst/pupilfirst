class AddUserIdToMoocStudent < ActiveRecord::Migration[4.2]
  def change
    add_column :mooc_students, :user_id, :integer
  end
end
