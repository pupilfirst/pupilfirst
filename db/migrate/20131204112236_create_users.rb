class CreateUsers < ActiveRecord::Migration[4.2]
  def change
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :fullname

      t.timestamps
    end
  end
end
