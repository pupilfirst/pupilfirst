class CreateFacultyStartupJoinTable < ActiveRecord::Migration[5.1]
  def change
    create_table :faculty_startups, id: false do |t|
      t.belongs_to :faculty, index: true
      t.belongs_to :startup, index: true
    end
  end
end
