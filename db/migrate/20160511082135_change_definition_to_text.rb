class ChangeDefinitionToText < ActiveRecord::Migration[4.2]
  def change
    change_column :glossaries, :definition, :text
  end
end
