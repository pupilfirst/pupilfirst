class RemoveCoolFactFromStartups < ActiveRecord::Migration
  def change
    remove_column :startups, :cool_fact, :string
  end
end
