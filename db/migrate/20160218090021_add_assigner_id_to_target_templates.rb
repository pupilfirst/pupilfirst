class AddAssignerIdToTargetTemplates < ActiveRecord::Migration[4.2]
  def change
    add_column :target_templates, :assigner_id, :integer
  end
end
