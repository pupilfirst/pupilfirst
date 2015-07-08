class DropTableNews < ActiveRecord::Migration
  def up
    drop_table :news
  end

  def down
    create_table 'news' do |t|
      t.string 'title'
      t.text 'body'
      t.integer 'user_id'
      t.boolean 'featured'
      t.string 'youtube_id'
      t.datetime 'created_at'
      t.datetime 'updated_at'
      t.string 'picture'
      t.boolean 'notification_sent'
      t.datetime 'published_at'
      t.integer 'category_id'
    end

    add_index :news, :user_id
  end
end
