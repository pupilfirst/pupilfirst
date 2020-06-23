class AddSchoolToMarkdownAttachments < ActiveRecord::Migration[6.0]
  class MarkdownAttachment < ApplicationRecord
    belongs_to :user
  end

  def up
    add_reference :markdown_attachments, :school, index: true

    MarkdownAttachment.all.includes(:user).find_each do |attachment|
      attachment.update!(school_id: attachment.user.school_id)
    end
  end

  def down
    remove_reference :markdown_attachments, :school
  end
end
