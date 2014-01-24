class ChangeColumnTypeForStartups < ActiveRecord::Migration
  def self.up
   change_column :startups, :about, :text
  end

  def self.down
   change_column :startups, :about, :string
  end
end
