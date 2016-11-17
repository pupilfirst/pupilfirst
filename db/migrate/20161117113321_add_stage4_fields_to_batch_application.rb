class AddStage4FieldsToBatchApplication < ActiveRecord::Migration[5.0]
  def change
    add_column :batch_applications, :courier_name, :string
    add_column :batch_applications, :courier_number, :string
    add_column :batch_applications, :partnership_deed, :string
    add_column :batch_applications, :payment_reference, :string
  end
end
