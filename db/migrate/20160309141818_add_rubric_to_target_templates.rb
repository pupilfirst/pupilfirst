class AddRubricToTargetTemplates < ActiveRecord::Migration
  def change
    add_column :target_templates, :rubric, :string
  end
end
