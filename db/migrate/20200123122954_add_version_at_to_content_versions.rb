class AddVersionAtToContentVersions < ActiveRecord::Migration[6.0]
  class ContentVersion < ActiveRecord::Base
  end

  def up
    add_column :content_versions, :version_at, :datetime

    ContentVersion.reset_column_information
    ContentVersion.all.each do |content_version|
      content_version.update!(version_at: content_version.version_on)
    end
  end

  def down
    ContentVersion.all.each do |content_version|
      content_version.update!(version_on: content_version.version_at)
    end
    remove_column :content_versions, :version_at, :datetime
  end
end
