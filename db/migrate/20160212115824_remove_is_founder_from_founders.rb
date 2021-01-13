class RemoveIsFounderFromFounders < ActiveRecord::Migration[4.2]
  def change
    remove_column :founders, :is_founder, :boolean
  end
end
