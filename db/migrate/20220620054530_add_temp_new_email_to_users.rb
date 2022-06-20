class AddTempNewEmailToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :temp_new_email, :string
  end
end
