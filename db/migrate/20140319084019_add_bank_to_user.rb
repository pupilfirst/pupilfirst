class AddBankToUser < ActiveRecord::Migration
  def change
    add_reference :users, :bank, index: true
  end
end
