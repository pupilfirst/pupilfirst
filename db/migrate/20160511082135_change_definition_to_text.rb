class ChangeDefinitionToText < ActiveRecord::Migration
  def change
    change_column :glossaries, :definition, :text
  end
end
