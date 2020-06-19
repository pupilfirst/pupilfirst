module MarkdownAttachments
  class CreateForm < Reform::Form
    attr_accessor :current_user

    property :file, virtual: true, validates: { presence: true, file_size: { less_than: 5.megabytes } }

    validate :prevent_abuse

    def prevent_abuse
      return if current_user.markdown_attachments.where('created_at >= ?', Time.zone.now.beginning_of_day).count < Rails.application.secrets.max_daily_markdown_attachments

      errors[:base] << 'You have exceeded the number of attachments allowed per day.'
    end

    def save
      current_user.markdown_attachments.create!(
        file: file,
        token: SecureRandom.urlsafe_base64,
        school: current_user.school
      )
    end
  end
end
