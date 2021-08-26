module Cloudfront
  class GenerateSignedUrlService
    def initialize(path)
      @path = path
    end

    def generate_url
      signer =
        Aws::CloudFront::UrlSigner.new(
          key_pair_id: Rails.application.secrets.cloudfront[:key_pair_id],
          private_key:
            Base64.decode64(Rails.application.secrets.cloudfront[:private_key])
        )

      signer.signed_url(
        "https://#{Rails.application.secrets.cloudfront[:host]}/#{@path}",
        expires: Time.zone.now + 10.minutes
      )
    end
  end
end
