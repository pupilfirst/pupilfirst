class CreateNews < ActiveRecord::Migration
  def change
    create_table :news do |t|
      t.string :title
      t.text :body
      t.references :user, index: true
      t.boolean :featured
      t.string :youtube_id
      t.string :youtube_thumbnail_url

      t.timestamps
    end
  end
end
