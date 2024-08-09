module MarkdownAttachments
  class CreateForm < Reform::Form
    attr_accessor :current_user

    property :file,
             virtual: true,
             validates: {
               presence: true,
               file_size: {
                 less_than: Settings.max_upload_file_size
               }
             }

    validate :prevent_abuse

    def prevent_abuse
      if current_user
           .markdown_attachments
           .where('created_at >= ?', Time.zone.now.beginning_of_day)
           .count < Settings.max_daily_markdown_attachments
        return
      end

      errors.add(
        :base,
        'You have exceeded the number of attachments allowed per day.'
      )
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
