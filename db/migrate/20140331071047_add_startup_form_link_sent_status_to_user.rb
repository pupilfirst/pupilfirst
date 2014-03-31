class AddStartupFormLinkSentStatusToUser < ActiveRecord::Migration
  def change
    add_column :users, :startup_form_link_sent_status, :boolean
  end
end
