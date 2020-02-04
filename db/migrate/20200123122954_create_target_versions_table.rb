class CreateTargetVersionsTable < ActiveRecord::Migration[6.0]
  class Target < ActiveRecord::Base
    has_many :content_versions, dependent: :destroy
    has_many :content_blocks, through: :content_versions
  end

  class ContentVersion < ActiveRecord::Base
    belongs_to :target
    belongs_to :content_block
  end

  class ContentBlock < ActiveRecord::Base
    has_many :content_versions, dependent: :restrict_with_error
    has_one_attached :file
  end

  class TargetVersion < ActiveRecord::Base

  end

  def up
    create_table :target_versions do |t|
      t.references :target, foreign_key: true

      t.timestamps
    end

    add_column :content_blocks, :sort_index, :integer, null: false, default: 0
    add_reference :content_blocks, :target_version, index: true

    TargetVersion.reset_column_information
    ContentBlock.reset_column_information

    ContentBlock.all.each do |content_block|
      content_versions = content_block.content_versions
      content_versions.each_with_index do |content_version, index|
        target_version = TargetVersion.where(created_at: content_version.version_on.beginning_of_day, target_id: content_version.target_id).first_or_create!
        if index.zero?
          content_block.update!(sort_index: content_version.sort_index, target_version_id: target_version.id)
        else
          new_content_block = content_block.dup
          new_content_block.sort_index = content_version.sort_index
          new_content_block.target_version_id = target_version
          new_content_block.save!
          new_content_block.file.attach(content_block.file.blob) if content_block.file.attached?
        end
      end
    end

  end

  def down
    remove_reference :content_blocks, :target_version
    remove_column :content_blocks, :sort_index
    drop_table :target_versions
  end
end
