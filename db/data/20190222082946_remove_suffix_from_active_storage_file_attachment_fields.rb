class RemoveSuffixFromActiveStorageFileAttachmentFields < ActiveRecord::Migration[5.2]
  def up
    # Rename Resource#file_as field
    ActiveStorage::Attachment.where(record_type: 'Resource').update_all(name: 'file')

    # Rename TimelineEventFile#file_as field
    ActiveStorage::Attachment.where(record_type: 'TimelineEventFile').update_all(name: 'file')

    # Rename Faculty#image_as field
    ActiveStorage::Attachment.where(record_type: 'Faculty').update_all(name: 'image')

    # Rename Founder#avatar_as field
    ActiveStorage::Attachment.where(record_type: 'Founder').update_all(name: 'avatar')
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
