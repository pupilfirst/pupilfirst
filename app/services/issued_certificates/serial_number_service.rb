module IssuedCertificates
  # Generates a new serial number with sufficient level of uniqueness.
  class SerialNumberService
    # Returns a unique 13-char serial number, with ~2.2B possibilities per day.
    def self.generate
      date = Time.now.utc.strftime("%y%m%d")
      token = rand(2_176_782_336).to_s(36).rjust(6, '0').upcase

      "#{date}-#{token}"
    end
  end
end
