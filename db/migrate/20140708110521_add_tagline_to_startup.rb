class AddTaglineToStartup < ActiveRecord::Migration[4.2]
  def change
    add_column :startups, :tagline, :string
  end
end
