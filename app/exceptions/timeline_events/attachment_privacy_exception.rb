module TimelineEvents
  class AttachmentPrivacyException < TimelineEvents::ReviewInterfaceException
    def message
      'Attachment needs to be public'
    end
  end
end
