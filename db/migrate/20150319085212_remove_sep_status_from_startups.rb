class RemoveSepStatusFromStartups < ActiveRecord::Migration
  def change
    remove_column :startups, :sep_status, :boolean
  end
end
