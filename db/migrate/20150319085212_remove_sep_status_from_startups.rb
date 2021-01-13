class RemoveSepStatusFromStartups < ActiveRecord::Migration[4.2]
  def change
    remove_column :startups, :sep_status, :boolean
  end
end
