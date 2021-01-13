class RenameStartupTaglineToCoolFact < ActiveRecord::Migration[4.2]
  def change
    rename_column :startups, :tagline, :cool_fact
  end
end
