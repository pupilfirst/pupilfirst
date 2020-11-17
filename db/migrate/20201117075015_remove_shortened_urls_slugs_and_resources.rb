class RemoveShortenedUrlsSlugsAndResources < ActiveRecord::Migration[6.0]
  class Tagging < ApplicationRecord
  end

  def up
    # Delete all tags associated with old "resources".
    Tagging.where(taggable_type: 'Resource').delete_all

    drop_table :shortened_urls
    remove_column :startups, :slug
    drop_table :target_resources
    drop_table :resources
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
