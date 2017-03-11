class CreateUserActivity < ActiveRecord::Migration[5.0]
  def change
    create_table :user_activities do |t|
      t.references :user, index: true, foreign_key: true
      t.string :role
      t.json :meta_data
    end
  end
end
