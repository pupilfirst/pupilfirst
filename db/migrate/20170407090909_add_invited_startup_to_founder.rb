class AddInvitedStartupToFounder < ActiveRecord::Migration[5.0]
  def change
    add_reference :founders, :invited_startup, index: true
  end
end
