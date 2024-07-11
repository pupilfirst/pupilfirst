require "rails_helper"

describe Users::ValidateResetTokenService do
  include ConfigHelper

  let(:reset_password_token) { SecureRandom.urlsafe_base64 }
  let(:reset_password_token_digest) do
    Digest::SHA2.base64digest(reset_password_token)
  end
  let(:time_limit) { nil }
  let(:sent_at) { Time.zone.now }
  let!(:user) do
    create :user,
           reset_password_token: reset_password_token_digest,
           reset_password_sent_at: sent_at
  end

  subject { described_class.new(reset_password_token) }

  around do |example|
    with_env(RESET_PASSWORD_TOKEN_TIME_LIMIT: time_limit.to_s) { example.run }
  end

  describe "#authenticate" do
    context "when the token does not match any user" do
      let!(:user) { create :user }

      it "returns nil" do
        expect(subject.authenticate).to eq(nil)
      end
    end

    context "when a time limit exists" do
      let(:time_limit) { 3 }

      context "within time limit" do
        let(:sent_at) { 1.minute.ago }

        it "returns user based on #reset_password_token" do
          expect(subject.authenticate).to eq(user)
        end
      end

      context "beyond the time limit" do
        let(:sent_at) { 4.minutes.ago }

        it "returns nil due to time limit" do
          expect(subject.authenticate).to eq(nil)
        end
      end
    end

    context "without a configured time limit" do
      context "within default time limit" do
        let(:sent_at) { 13.minutes.ago }

        it "returns user based on #reset_password_token" do
          expect(subject.authenticate).to eq(user)
        end
      end

      context "beyond the default time limit" do
        let(:sent_at) { 16.minutes.ago }

        it "returns nil due to time limit" do
          expect(subject.authenticate).to eq(nil)
        end
      end
    end
  end
end
