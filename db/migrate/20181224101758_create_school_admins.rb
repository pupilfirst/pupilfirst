class CreateSchoolAdmins < ActiveRecord::Migration[5.2]
  def change
    create_table :school_admins do |t|
      t.references :user, foreign_key: true
      t.references :school, foreign_key: true, index: true

      t.timestamps
    end

    add_index :school_admins, %i[user_id school_id], unique: true
  end
end
