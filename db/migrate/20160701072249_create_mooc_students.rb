class CreateMoocStudents < ActiveRecord::Migration
  def change
    create_table :mooc_students do |t|
      t.string :email
      t.string :name
      t.integer :university_id
      t.string :college
      t.string :semester
      t.string :state
      t.string :gender

      t.timestamps null: false
    end
  end
end
