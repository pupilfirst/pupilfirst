class AddCollegeTextToMoocStudent < ActiveRecord::Migration[5.0]
  def change
    add_column :mooc_students, :college_text, :string
  end
end
