require 'aws-sdk-cloudfront'

module Cloudfront
  class GenerateSignedUrlService
    def initialize(blob)
      @blob = blob
    end

    def generate_url
      signer =
        Aws::CloudFront::UrlSigner.new(
          key_pair_id: Rails.application.secrets.cloudfront[:key_pair_id],
          private_key:
            Base64.decode64(Rails.application.secrets.cloudfront[:private_key])
        )

      uri =
        URI(
          "https://#{Rails.application.secrets.cloudfront[:host]}/#{@blob.key}"
        )

      blob =
        if @blob.is_a?(ActiveStorage::Variant) ||
             @blob.is_a?(ActiveStorage::VariantWithRecord)
          @blob.blob
        else
          @blob
        end

      content_disposition =
        if MIME::Types[blob.content_type].first&.media_type == 'image'
          'inline'
        else
          'attachment'
        end

      uri.query = {
        'response-content-disposition':
          "#{content_disposition}; filename=\"#{blob.filename}\";",
        'response-content-type': blob.content_type
      }.to_query

      signer.signed_url(
        uri.to_s,
        expires:
          Time.zone.now + Rails.application.secrets.cloudfront[:expiry].seconds
      )
    end
  end
end
