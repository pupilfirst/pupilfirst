class RemoveOtherNameFromUser < ActiveRecord::Migration
  def change
    remove_reference :users, :other_name, index: true
  end
end
