class AddExitedToFounders < ActiveRecord::Migration
  def change
    add_column :founders, :exited, :boolean, default: false
  end
end
