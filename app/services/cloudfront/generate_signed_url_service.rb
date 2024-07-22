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
          key_pair_id: Settings.cloudfront.key_pair_id,
          private_key:
            Base64.decode64(Settings.cloudfront.private_key)
        )

      uri =
        URI(
          "https://#{Settings.cloudfront.host}/#{@blob.key}"
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
          "#{content_disposition}; filename=\"#{URI.encode_www_form_component(blob.filename)}\";",
        "response-content-type": blob.content_type
      }.to_query

      signer.signed_url(
        uri.to_s,
        expires:
          Time.zone.now + Settings.cloudfront.expiry.seconds
      )
    end
  end
end
