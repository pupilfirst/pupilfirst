class AddPhoneToMoocStudent < ActiveRecord::Migration[4.2]
  def change
    add_column :mooc_students, :phone, :string
  end
end
