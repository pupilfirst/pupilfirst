class CreateLeaderboardEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :leaderboard_entries do |t|
      t.references :founder, foreign_key: true
      t.datetime :period_from, null: false
      t.datetime :period_to, null: false
      t.integer :score, null: false

      t.timestamps
    end

    add_index :leaderboard_entries, %i[founder_id period_from period_to], unique: true, name: 'index_leaderboard_entries_on_founder_id_and_period'
  end
end
