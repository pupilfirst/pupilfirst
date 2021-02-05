class AddNotificationsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.references :actor
      t.references :recipient
      t.references :notifiable, polymorphic: true, index: true
      t.datetime :read_at
      t.text :message
      t.string :event

      t.timestamps
    end

    create_table :topic_subscriptions do |t|
      t.references :topic, index: false
      t.references :user

      t.timestamps
    end

    add_index :topic_subscriptions, %i[topic_id user_id], unique: true
  end
end
