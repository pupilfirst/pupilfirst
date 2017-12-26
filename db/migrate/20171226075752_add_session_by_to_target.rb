class AddSessionByToTarget < ActiveRecord::Migration[5.1]
  def change
    add_column :targets, :session_by, :string
  end
end
