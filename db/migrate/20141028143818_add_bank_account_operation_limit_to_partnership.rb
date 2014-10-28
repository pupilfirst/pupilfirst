class AddBankAccountOperationLimitToPartnership < ActiveRecord::Migration
  def change
    add_column :partnerships, :bank_account_operation_limit, :integer
  end
end
