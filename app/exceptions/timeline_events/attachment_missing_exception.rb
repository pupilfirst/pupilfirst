module TimelineEvents
  # Raised when attachment is
  class AttachmentMissingException < TimelineEvents::ReviewInterfaceException
    def message
      'Attachment Missing'
    end
  end
end
