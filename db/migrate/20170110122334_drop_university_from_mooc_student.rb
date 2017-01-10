class DropUniversityFromMoocStudent < ActiveRecord::Migration[5.0]
  def change
    remove_column :mooc_students, :university_id, :integer
  end
end
