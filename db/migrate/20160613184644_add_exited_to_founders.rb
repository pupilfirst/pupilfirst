class AddExitedToFounders < ActiveRecord::Migration[4.2]
  def change
    add_column :founders, :exited, :boolean, default: false
  end
end
