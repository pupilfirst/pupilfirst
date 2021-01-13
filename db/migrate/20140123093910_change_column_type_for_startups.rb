class ChangeColumnTypeForStartups < ActiveRecord::Migration[4.2]
  def self.up
   change_column :startups, :about, :text
  end

  def self.down
   change_column :startups, :about, :string
  end
end
