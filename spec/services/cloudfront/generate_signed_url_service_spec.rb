require "rails_helper"

RSpec.describe Cloudfront::GenerateSignedUrlService do
  let(:blob) do
    instance_double(
      "ActiveStorage::Blob",
      key: "file_key",
      content_type: "image/png",
      filename: "example.png"
    )
  end

  let(:variant) do
    instance_double(
      "ActiveStorage::Variant",
      blob: blob,
      key: "variant_key",
      content_type: "image/png",
      filename: "example.png"
    )
  end

  let(:url_signer) { instance_double("Aws::CloudFront::UrlSigner") }
  let(:signed_url) { "https://example.cloudfront.net/signed-url" }
  let(:expiry_time) { 1.hour }

  before do
    # Mocking UrlSigner to avoid external API call
    allow(Aws::CloudFront::UrlSigner).to receive(:new).with(
      key_pair_id: "fake_key_pair_id",
      private_key: "fake_private_key_encoded"
    ).and_return(url_signer)

    allow(url_signer).to receive(:signed_url).and_return(signed_url)

    # Stubbing secrets as they are environment dependent
    allow(Settings).to receive(:cloudfront).and_return(Config::Options.new(
      key_pair_id: "fake_key_pair_id",
      private_key: Base64.encode64("fake_private_key_encoded"),
      host: "example.cloudfront.net",
      expiry: expiry_time
    ))
  end

  subject(:service) { described_class.new(blob) }

  context "when blob is a simple file" do
    it "generates a signed URL with proper content disposition" do
      expect(service.generate_url).to eq(signed_url)

      expect(url_signer).to have_received(:signed_url) do |url, options|
        expect(url).to include("https://example.cloudfront.net/file_key")
        expect(options[:expires]).to be_within(1.minute).of(
          Time.zone.now + expiry_time.seconds
        )
      end
    end
  end

  context "when blob is a variant" do
    subject(:service) { described_class.new(variant) }

    it "generates a signed URL for the variant blob" do
      expect(service.generate_url).to eq(signed_url)

      expect(url_signer).to have_received(:signed_url) do |url, _options|
        expect(url).to include("https://example.cloudfront.net/variant_key")
      end
    end
  end

  context "with different file content types" do
    let(:unsafe_content_type) { "application/zip" }

    before do
      allow(blob).to receive(:content_type).and_return(unsafe_content_type)
    end

    it "adjusts content disposition based on content type" do
      service.generate_url
      expect(url_signer).to have_received(:signed_url) do |url, _options|
        expect(url).to include("response-content-disposition=attachment")
      end
    end
  end

  context "when the filename contains special characters" do
    let(:blob) do
      instance_double(
        "ActiveStorage::Blob",
        key: "file_key",
        content_type: "image/png",
        filename: "മലയാളം.png" # filename that requires URL encoding
      )
    end

    it "escapes the filename in content disposition" do
      service.generate_url
      expect(url_signer).to have_received(:signed_url) do |url, _options|
        uri = URI.parse(url)
        query_params = CGI.parse(uri.query)
        content_disposition = query_params["response-content-disposition"].first

        # Make sure that the filename has been properly escaped
        expect(content_disposition).to include(
          'filename="%E0%B4%AE%E0%B4%B2%E0%B4%AF%E0%B4%BE%E0%B4%B3%E0%B4%82.png"'
        )
      end
    end
  end
end
