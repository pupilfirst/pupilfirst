class RemoveSchoolIdFromSchoolAdmin < ActiveRecord::Migration[6.1]
  def change
    remove_column :school_admins, :school_id
  end
end
