class RenameDbConfigToFeature < ActiveRecord::Migration[4.2]
  def change
    rename_table :db_configs, :features
  end
end
