class UpdateUserActivity < ActiveRecord::Migration[5.0]
  def change
    change_table :user_activities do |t|
      t.timestamps
      t.rename :meta_data, :metadata
      t.rename :role, :activity_type
    end
  end
end

