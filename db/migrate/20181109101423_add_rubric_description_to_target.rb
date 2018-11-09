class AddRubricDescriptionToTarget < ActiveRecord::Migration[5.2]
  def change
    add_column :targets, :rubric_description, :text
  end
end
