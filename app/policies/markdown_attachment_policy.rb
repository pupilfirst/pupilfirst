class MarkdownAttachmentPolicy < ApplicationPolicy
  def create?
    # All registered users can create markdown attachments.
    user.present?
  end

  def download?
    # All registered users in the attachment uploader's school can access it.
    record.user.school == current_school
  end
end
