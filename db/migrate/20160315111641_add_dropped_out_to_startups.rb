class AddDroppedOutToStartups < ActiveRecord::Migration
  def change
    add_column :startups, :dropped_out, :boolean, default: false
  end
end
