class AddActionConfigToTarget < ActiveRecord::Migration[6.1]
  def change
    add_column :targets, :action_config, :text
  end
end
