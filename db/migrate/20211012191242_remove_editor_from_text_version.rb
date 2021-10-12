class RemoveEditorFromTextVersion < ActiveRecord::Migration[6.1]
  def change
    remove_column :text_versions, :editor_id, :string
  end
end
