class CreateUserStandings < ActiveRecord::Migration[6.1]
  def change
    create_table :user_standings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :standing, null: false, foreign_key: true
      t.text :reason
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.references :archiver, foreign_key: { to_table: :users }
      t.datetime :archived_at

      t.timestamps
    end
  end
end
