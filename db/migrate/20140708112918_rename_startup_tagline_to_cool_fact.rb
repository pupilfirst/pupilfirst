class RenameStartupTaglineToCoolFact < ActiveRecord::Migration
  def change
    rename_column :startups, :tagline, :cool_fact
  end
end
