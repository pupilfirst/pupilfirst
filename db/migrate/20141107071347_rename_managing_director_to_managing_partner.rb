class RenameManagingDirectorToManagingPartner < ActiveRecord::Migration[4.2]
  def change
    rename_column :partnerships, :managing_director, :managing_partner
  end
end
