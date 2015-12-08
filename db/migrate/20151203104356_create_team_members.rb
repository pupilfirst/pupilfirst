class CreateTeamMembers < ActiveRecord::Migration
  def change
    create_table :team_members do |t|
      t.string :name
      t.string :email
      t.string :roles
      t.string :avatar
      t.references :startup, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
