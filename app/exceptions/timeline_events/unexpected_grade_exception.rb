module TimelineEvents
  # Raised when grade specified is blank or is not one among TimelineEvent#valid_grades
  class UnexpectedGradeException < TimelineEvents::ReviewInterfaceException
    def message
      'Unexpected grade specified'
    end
  end
end
