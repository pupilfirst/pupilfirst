module Schools
  class RegisterSenderSignatureService
    def initialize(school)
      @school = school
    end

    def register(name, email_address)
      prevent_duplication

      return random_id if Rails.env.development?

      client = PostmarkClient.new(Rails.application.secrets.postmark[:api_token])
      response = client.create_sender_signature(name, email_address)
      response[:id]
    end

    private

    def prevent_duplication
      if configuration["emailSenderSignature"].present?
        raise "Email sender signature is already present for school with ID #{@school.id}"
      end
    end

    def configuration
      @configuration ||= @school.configuration.dup
    end

    def random_id
      rand(1..100_000)
    end
  end
end
