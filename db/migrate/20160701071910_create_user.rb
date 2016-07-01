class CreateUser < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :login_token
    end
  end
end
