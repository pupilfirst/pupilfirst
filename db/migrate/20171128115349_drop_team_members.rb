class DropTeamMembers < ActiveRecord::Migration[5.1]
  def up
    drop_table :team_members
  end

  def down
    create_table :team_members do |t|
      t.string :name
      t.string :email
      t.string :roles
      t.string :avatar
      t.references :startup, index: true
      t.boolean :avatar_processing, default: false

      t.timestamps
    end
  end
end
