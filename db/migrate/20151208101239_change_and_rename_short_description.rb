class ChangeAndRenameShortDescription < ActiveRecord::Migration
  def self.up
    change_column :target_templates, :short_description, :text
    rename_column :target_templates, :short_description, :description
    change_column :targets, :short_description, :text
    rename_column :targets, :short_description, :description
  end

  def self.down
    rename_column :target_templates, :description, :short_description
    change_column :target_templates, :short_description, :string
    rename_column :targets, :description, :short_description
    change_column :targets, :short_description, :string
  end
end
