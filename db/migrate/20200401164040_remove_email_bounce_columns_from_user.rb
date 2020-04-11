class RemoveEmailBounceColumnsFromUser < ActiveRecord::Migration[6.0]
  def change
    remove_column :users, :email_bounced_at, :datetime
    remove_column :users, :email_bounce_type, :string
  end
end
