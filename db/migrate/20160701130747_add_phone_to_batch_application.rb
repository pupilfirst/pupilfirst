class AddPhoneToBatchApplication < ActiveRecord::Migration
  def change
    add_column :batch_applications, :phone, :string
  end
end
