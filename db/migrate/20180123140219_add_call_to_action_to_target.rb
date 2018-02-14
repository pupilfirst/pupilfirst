class AddCallToActionToTarget < ActiveRecord::Migration[5.1]
  def change
    add_column :targets, :call_to_action, :string
  end
end
