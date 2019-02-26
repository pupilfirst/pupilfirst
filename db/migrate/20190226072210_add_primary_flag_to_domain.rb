class AddPrimaryFlagToDomain < ActiveRecord::Migration[5.2]
  def change
    add_column :domains, :primary, :boolean, default: false
  end
end
