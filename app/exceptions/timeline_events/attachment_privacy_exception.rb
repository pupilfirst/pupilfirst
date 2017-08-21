module TimelineEvents
  # Raised when grade specified is blank or is not one among TimelineEvent#valid_grades
  class AttachmentPrivacyException < TimelineEvents::ReviewInterfaceException
    def message
      'Attachment needs to be public'
    end
  end
end
