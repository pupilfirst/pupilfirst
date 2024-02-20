class RemoveSchoolFromSchoolAdmins < ActiveRecord::Migration[6.1]
  def change
    remove_index :school_admins, %i[user_id school_id], unique: true
    remove_reference :school_admins, :school, foreign_key: true, index: true
    remove_index :school_admins, :user_id
    add_index :school_admins, :user_id, unique: true
  end
end
