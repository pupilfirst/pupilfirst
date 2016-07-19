class AddPhoneToMoocStudent < ActiveRecord::Migration
  def change
    add_column :mooc_students, :phone, :string
  end
end
