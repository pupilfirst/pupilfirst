class AddUserIdToFounder < ActiveRecord::Migration[5.0]
  def change
    add_reference :founders, :user, foreign_key: true
  end
end
