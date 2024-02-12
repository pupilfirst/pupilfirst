class CreateStandingsAndUserStandings < ActiveRecord::Migration[7.0]
  def change
    create_table :standings do |t|
      t.string :name
      t.string :color
      t.text :description
      t.boolean :default, null: false, default: false
      t.datetime :archived_at, index: true

      t.references :school, null: false, foreign_key: true

      t.timestamps
    end

    add_index :standings, %i[name school_id], unique: true
    add_index :standings, :default, where: '("default" = true)'

    create_table :user_standings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :standing, null: false, foreign_key: true
      t.text :reason
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.references :archiver, foreign_key: { to_table: :users }
      t.datetime :archived_at, index: true

      t.timestamps
    end
  end
end
