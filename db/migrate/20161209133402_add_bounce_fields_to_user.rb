class AddBounceFieldsToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :email_bounced, :boolean
    add_column :users, :email_bounced_at, :datetime
    add_column :users, :email_bounce_type, :string
  end
end
