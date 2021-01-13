class RemoveCoolFactFromStartups < ActiveRecord::Migration[4.2]
  def change
    remove_column :startups, :cool_fact, :string
  end
end
