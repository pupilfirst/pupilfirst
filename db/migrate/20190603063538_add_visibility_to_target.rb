class AddVisibilityToTarget < ActiveRecord::Migration[5.2]
  def change
    add_column :targets, :visibility, :string
  end
end
