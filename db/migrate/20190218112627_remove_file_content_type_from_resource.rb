class RemoveFileContentTypeFromResource < ActiveRecord::Migration[5.2]
  def change
    remove_column :resources, :file_content_type, :integer
  end
end
