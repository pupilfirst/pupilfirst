module Schools
  class RegisterSenderSignatureService
    def initialize(school)
      @school = school
    end

    def register(name, email_address)
      client = PostmarkClient.new(Rails.application.secrets.postmark[:api_token])

      if configuration["emailSenderSignature"].present?
        raise "Email sender signature is already present for school with ID #{@school.id}"
      end

      response = client.create_sender_signature(name, email_address)
      response[:id]
    end

    def configuration
      @configuration ||= @school.configuration.dup
    end
  end
end
