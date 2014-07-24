class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.text :body
      t.references :user

      t.timestamps
    end
  end
end
