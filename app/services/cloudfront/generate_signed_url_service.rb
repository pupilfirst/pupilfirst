require "aws-sdk-cloudfront"

module Cloudfront
  class GenerateSignedUrlService
    SAFE_INLINE_FORMATS = %w[
      image/jpeg
      image/png
      image/gif
      image/webp
      image/tiff
      image/bmp
      image/x-icon
      application/pdf
    ].freeze

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
        if SAFE_INLINE_FORMATS.include?(blob.content_type)
          "inline"
        else
          "attachment"
        end

      uri.query = {
        "response-content-disposition":
          "#{content_disposition}; filename=\"#{blob.filename}\";",
        "response-content-type": blob.content_type
      }.to_query

      signer.signed_url(
        uri.to_s,
        expires:
          Time.zone.now + Rails.application.secrets.cloudfront[:expiry].seconds
      )
    end
  end
end
