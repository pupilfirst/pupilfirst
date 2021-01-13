class DropTableRequests < ActiveRecord::Migration[4.2]
  def up
    drop_table :requests
  end

  def down
    create_table 'requests' do |t|
      t.text 'body'
      t.integer 'user_id'
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end
  end
end
