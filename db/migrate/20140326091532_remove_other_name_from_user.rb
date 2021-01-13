class RemoveOtherNameFromUser < ActiveRecord::Migration[4.2]
  def change
    remove_reference :users, :other_name, index: true
  end
end
