class CreateFaculty < ActiveRecord::Migration
  def change
    create_table :faculty do |t|
      t.string :name
      t.string :title
      t.string :key_skills
      t.string :linkedin_url
      t.string :category
      t.boolean :available_for_connect
      t.string :availability

      t.timestamps null: false
    end
  end
end
