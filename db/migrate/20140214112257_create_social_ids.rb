class CreateSocialIds < ActiveRecord::Migration
  def change
    create_table :social_ids do |t|
      t.string :provider, index: true
      t.references :user, index: true
      t.string :social_id, index: true
      t.string :social_token, limit: 500
      t.boolean :primary, index: true
      t.string :permission

      t.timestamps
    end
  end
end
