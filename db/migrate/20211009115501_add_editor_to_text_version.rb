class AddEditorToTextVersion < ActiveRecord::Migration[6.1]
  def change
    add_column :text_versions, :editor_id, :string
  end
end
