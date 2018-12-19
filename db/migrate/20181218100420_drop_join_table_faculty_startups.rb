class DropJoinTableFacultyStartups < ActiveRecord::Migration[5.2]
  def change
    drop_join_table(:faculty, :startups) do |t|
      t.index :startup_id
      t.index [:faculty_id, :startup_id], unique: true
    end
  end
end
