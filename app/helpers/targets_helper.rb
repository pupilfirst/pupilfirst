# Temporary helper for now. Will be moved to decoraters.
# rubocop:disable Metrics/CyclomaticComplexity
module TargetsHelper
  def status_class(status)
    case status
      when :complete
        'verified'
      when :needs_improvement
        'needs-improvement'
      when :submitted
        'submitted'
      when :expired
        'expired'
      when :pending
        'pending'
      when :unavailable
        'unavailable'
    end
  end

  def status_text(status)
    case status
      when :complete
        'Complete'
      when :needs_improvement
        'Needs Improvement'
      when :submitted
        'Submitted'
      when :expired
        'Expired'
      when :pending
        'Pending'
      when :unavailable
        'Unavailable'
    end
  end
end
# rubocop:enable Metrics/CyclomaticComplexity
