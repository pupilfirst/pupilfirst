class AddCofounderCountToBatchApplication < ActiveRecord::Migration[4.2]
  def change
    add_column :batch_applications, :cofounder_count, :integer
  end
end
