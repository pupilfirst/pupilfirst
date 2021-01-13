class AddUserToEvent < ActiveRecord::Migration[4.2]
  def change
    add_reference :events, :user, index: true
  end
end
