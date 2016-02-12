class RemoveIsFounderFromFounders < ActiveRecord::Migration
  def change
    remove_column :founders, :is_founder, :boolean
  end
end
