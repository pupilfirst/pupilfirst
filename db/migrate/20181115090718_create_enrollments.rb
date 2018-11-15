class CreateEnrollments < ActiveRecord::Migration[5.2]
  def change
    create_table :enrollments do |t|
      t.references :founder, foreign_key: true, index: false
      t.references :user, foreign_key: true
    end

    add_index :enrollments, [:founder_id, :user_id], unique: true
  end
end
