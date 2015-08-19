class RemoveStartupFormLinkSentStatusFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :startup_form_link_sent_status, :boolean
  end
end
