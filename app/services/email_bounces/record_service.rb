module EmailBounces
  # Shared suppression persistence for Postmark and future SMTP event adapters.
  # Only permanent delivery failures and spam complaints are recorded.
  class RecordService
    TYPES = %w[HardBounce SpamComplaint].freeze

    def self.call(email:, type:)
      return unless TYPES.include?(type)

      normalized_email = email.to_s.strip
      return if normalized_email.blank?

      # bounce_reports.email has a unique citext index; first event wins.
      BounceReport.create_or_find_by!(email: normalized_email) do |report|
        report.bounce_type = type
      end
    end
  end
end
