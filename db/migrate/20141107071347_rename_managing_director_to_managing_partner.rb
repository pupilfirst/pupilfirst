class RenameManagingDirectorToManagingPartner < ActiveRecord::Migration
  def change
    rename_column :partnerships, :managing_director, :managing_partner
  end
end
