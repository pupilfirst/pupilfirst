class AddPublicPreviewToCourse < ActiveRecord::Migration[6.0]
  def change
    add_column :courses, :public_preview, :boolean, default: false
  end
end
