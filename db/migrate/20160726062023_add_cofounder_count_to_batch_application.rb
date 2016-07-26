class AddCofounderCountToBatchApplication < ActiveRecord::Migration
  def change
    add_column :batch_applications, :cofounder_count, :integer
  end
end
