require 'rails_helper'

describe OmniauthProviderUrlService do
  subject { described_class.new(provider, host) }

  let(:host) { Faker::Internet.domain_name }

  describe '#oauth_url' do
    context 'when the provider is google' do
      let(:provider) { 'google' }

      it 'returns Google Omniauth OAuth URL' do
        expect(subject.oauth_url).to eq("http://#{host}/users/auth/google_oauth2")
      end
    end

    context 'when the provider is facebook' do
      let(:provider) { 'facebook' }

      it 'returns Facebook Omniauth OAuth URL' do
        expect(subject.oauth_url).to eq("http://#{host}/users/auth/facebook")
      end
    end

    context 'when the provider is github' do
      let(:provider) { 'github' }

      it 'returns Github Omniauth OAuth URL' do
        expect(subject.oauth_url).to eq("http://#{host}/users/auth/github")
      end
    end

    context 'when the provider is something else' do
      let(:provider) { Faker::Lorem.word }

      it 'raises an error' do
        expect { subject.oauth_url }.to raise_error("Invalid provider #{provider} supplied to oauth redirection route.")
      end
    end
  end
end
