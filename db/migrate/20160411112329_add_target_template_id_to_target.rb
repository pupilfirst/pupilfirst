class AddTargetTemplateIdToTarget < ActiveRecord::Migration
  def change
    add_reference :targets, :target_template, index: true
  end
end
