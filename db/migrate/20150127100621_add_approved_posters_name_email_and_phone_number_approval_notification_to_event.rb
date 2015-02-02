class AddApprovedPostersNameEmailAndPhoneNumberApprovalNotificationToEvent < ActiveRecord::Migration
  def change
  	add_column :events, :approved, :boolean, default: false
    add_column :events, :posters_name, :string
    add_column :events, :posters_email, :string
    add_column :events, :posters_phone_number, :string
    add_column :events, :approval_notification_sent, :boolean, default: false
  end
end
