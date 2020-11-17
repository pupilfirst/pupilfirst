class RemoveShortenedUrlsAndOtherTables < ActiveRecord::Migration[6.0]
  class Tagging < ApplicationRecord
  end

  def up
    # Delete all tags associated with old "resources".
    Tagging.where(taggable_type: 'Resource').delete_all

    drop_table :shortened_urls
    remove_column :startups, :slug
    drop_table :target_resources
    drop_table :resources
    drop_table :active_admin_comments
    drop_table :user_activities
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
