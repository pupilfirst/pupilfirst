module TimelineEvents
  # Raised when verification status is not one among TimelineEvent#valid_statuses
  class UnexpectedStatusException < TimelineEvents::ReviewInterfaceException
    def message
      'Unexpected status specified'
    end
  end
end
