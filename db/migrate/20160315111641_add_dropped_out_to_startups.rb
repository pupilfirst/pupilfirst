class AddDroppedOutToStartups < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :dropped_out, :boolean, default: false
  end
end
