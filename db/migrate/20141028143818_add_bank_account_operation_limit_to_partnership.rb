class AddBankAccountOperationLimitToPartnership < ActiveRecord::Migration[4.2]
  def change
    add_column :partnerships, :bank_account_operation_limit, :integer
  end
end
