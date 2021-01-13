class AddPhoneToBatchApplication < ActiveRecord::Migration[4.2]
  def change
    add_column :batch_applications, :phone, :string
  end
end
