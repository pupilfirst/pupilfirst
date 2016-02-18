class AddAssignerIdToTargetTemplates < ActiveRecord::Migration
  def change
    add_column :target_templates, :assigner_id, :integer
  end
end
