require "rails_helper"

describe "Beckn inbound webhook" do
  let(:payload) do
    {
      "context" => {
        "ttl" => "PT10M",
        "action" => "select",
        "timestamp" => "2024-07-08T08:50:36.740Z",
        "message_id" => "72db3851-d935-4651-aa3d-d9d34ce42633",
        "transaction_id" => "a9aaecca-10b7-4d19-b640-b047a7c62196",
        "domain" => "dsep:courses",
        "version" => "1.1.0",
        "bap_id" => "dummy-bap-id",
        "bap_uri" => "https://dummy-bap-uri.com",
        "location" => {
          "city" => {
            "name" => "Bangalore",
            "code" => "std:080"
          },
          "country" => {
            "name" => "India",
            "code" => "IND"
          }
        },
        "bpp_id" => "dummy-bpp-id",
        "bpp_uri" => "https://dummy-bpp-uri.com"
      },
      "message" => {
        "order" => {
          "provider" => {
            "id" => "1"
          },
          "items" => [{ "id" => "1" }],
          "type" => "DEFAULT"
        }
      }
    }.to_json
  end

  def post_with_headers(payload, headers = {})
    post "/inbound_webhooks/beckn", params: payload, headers: headers
  end

  describe "POST /inbound_webhooks/beckn" do
    context "when HMAC is enabled" do
      before do
        Rails.application.secrets.beckn = {
          webhook_hmac_key: "juWDOTzzK7Eyrzm6hZwQmlJkolesm8x0"
        }
      end

      let(:secret) { Rails.application.secrets.beckn[:webhook_hmac_key] }
      let(:hmac) { OpenSSL::HMAC.hexdigest("SHA256", secret, payload) }
      let(:headers) { { "Authorization" => "HMAC-SHA-256 #{hmac}" } }

      context "with valid HMAC signature" do
        it "returns http success" do
          post_with_headers(payload, headers)
          expect(response).to have_http_status(:ok)
        end
      end

      context "with missing authorization header" do
        it "returns unauthorized" do
          post_with_headers(payload)
          expect(response).to have_http_status(:unauthorized)
          expect(response.parsed_body["message"]).to eq(
            "Missing authorization header"
          )
        end
      end

      context "with invalid signature format" do
        it "returns unauthorized" do
          invalid_headers = { "Authorization" => "HMAC-SHA-512 #{hmac}" }
          post_with_headers(payload, invalid_headers)

          expect(response).to have_http_status(:unauthorized)
          expect(response.parsed_body["message"]).to eq(
            "Invalid signature format"
          )
        end
      end

      context "with invalid HMAC signature" do
        it "returns unauthorized" do
          invalid_headers = { "Authorization" => "HMAC-SHA-256 invalid_hmac" }
          post_with_headers(payload, invalid_headers)

          expect(response).to have_http_status(:unauthorized)
          expect(response.parsed_body["message"]).to eq("Invalid signature")
        end
      end
    end

    context "when HMAC is disabled" do
      before { Rails.application.secrets.beckn = {} }

      it "returns http success" do
        post_with_headers(payload)

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
