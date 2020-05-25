class CleanupUserColumnsAndTables < ActiveRecord::Migration[6.0]
  def up
    remove_column :users, :phone
    remove_column :users, :communication_address
    remove_column :users, :key_skills
    remove_column :users, :resume_url
    remove_column :users, :blog_url
    remove_column :users, :personal_website_url
    remove_column :users, :linkedin_url
    remove_column :users, :twitter_url
    remove_column :users, :facebook_url
    remove_column :users, :angel_co_url
    remove_column :users, :github_url
    remove_column :users, :behance_url
    remove_column :users, :skype_id

    drop_table :prospective_applicants

    remove_column :targets, :google_calendar_event_id
    remove_column :faculty, :self_service
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
