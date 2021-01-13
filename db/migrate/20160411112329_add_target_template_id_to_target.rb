class AddTargetTemplateIdToTarget < ActiveRecord::Migration[4.2]
  def change
    add_reference :targets, :target_template, index: true
  end
end
