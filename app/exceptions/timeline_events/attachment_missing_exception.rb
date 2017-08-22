module TimelineEvents
  # Raised when attachment is
  class AttachmentMissingException < TimelineEvents::ReviewInterfaceException
    def message
      'No file/link in attachments'
    end
  end
end
