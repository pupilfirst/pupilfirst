class CreatePublicSlackMessages < ActiveRecord::Migration
  def change
    create_table :public_slack_messages do |t|
      t.text :body
      t.string :slack_username

      t.timestamps null: false
    end
  end
end
