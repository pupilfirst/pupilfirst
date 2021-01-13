class AddStartupFormLinkSentStatusToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :startup_form_link_sent_status, :boolean
  end
end
