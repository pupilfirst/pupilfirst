module OneOff
  class FounderResumeFileUpdateService
    include Loggable

    REGEX_RESUME_URL = %r{timeline_event_files/(?<timeline_event_file_id>[\d]+)/download}

    def update
      admitted_founders = Founder.admitted.not_exited

      founders_with_regex_mismatch = []
      updated_founders = []

      admitted_founders.each do |founder|
        next if founder.resume_url.blank?

        match = founder.resume_url.match(REGEX_RESUME_URL)

        if match.present?
          updated_founders << founder.id
          founder.update!(resume_file_id: match[:timeline_event_file_id], resume_url: nil)
        else
          founders_with_regex_mismatch << founder.id
        end
      end

      log "#{updated_founders.count} founders were updated with resume_file_id"
      log "#{founders_with_regex_mismatch.count} founders have regex mismatch in url. The ids are listed below:"

      founders_with_regex_mismatch
    end
  end
end
