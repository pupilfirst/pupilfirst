class AddRubricToTargetTemplates < ActiveRecord::Migration[4.2]
  def change
    add_column :target_templates, :rubric, :string
  end
end
