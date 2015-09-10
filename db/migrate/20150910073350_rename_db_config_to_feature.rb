class RenameDbConfigToFeature < ActiveRecord::Migration
  def change
    rename_table :db_configs, :features
  end
end
