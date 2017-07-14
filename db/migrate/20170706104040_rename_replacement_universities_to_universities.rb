class RenameReplacementUniversitiesToUniversities < ActiveRecord::Migration[5.1]
  def change
    rename_table :replacement_universities, :universities
    rename_column :colleges, :replacement_university_id, :university_id
  end
end
