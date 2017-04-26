class RemoveShareStatusFromResource < ActiveRecord::Migration[5.0]
  def change
    remove_column :resources, :share_status, :string
  end
end
