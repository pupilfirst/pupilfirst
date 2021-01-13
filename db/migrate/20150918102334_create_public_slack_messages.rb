class CreatePublicSlackMessages < ActiveRecord::Migration[4.2]
  def change
    create_table :public_slack_messages do |t|
      t.text :body
      t.string :slack_username
      t.references :user, index: true
      t.string :channel

      t.timestamps null: false
    end
  end
end
