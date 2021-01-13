class AddBankToUser < ActiveRecord::Migration[4.2]
  def change
    add_reference :users, :bank, index: true
  end
end
