class RemoveStateFromMoocStudent < ActiveRecord::Migration[5.1]
  def change
    remove_column :mooc_students, :state, :string
  end
end
