class UpdateIndexToSchoolAdminsOnUserId < ActiveRecord::Migration[6.1]
  def change
    remove_index :school_admins, :user_id
    add_index :school_admins, :user_id, unique: true
  end
end
