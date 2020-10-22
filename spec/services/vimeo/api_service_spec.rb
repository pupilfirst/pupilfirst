require 'rails_helper'

describe Vimeo::ApiService do
  include WithEnvHelper

  subject { described_class.new(school) }

  let(:school) { create :school, :current }
  let(:vimeo_access_token) { SecureRandom.hex }

  describe '#create_video' do
    let(:size) { rand(1000..100_000) }
    let(:name) { Faker::Lorem.words(number: 4).join(' ') }
    let(:description) { Faker::Lorem.paragraph }

    let(:expected_data) do
      {
        upload: {
          approach: 'tus',
          size: size
        },
        privacy: {
          embed: 'whitelist',
          view: 'disable'
        },
        embed: {
          buttons: {
            like: false,
            watchlater: false,
            share: false
          },
          logos: {
            vimeo: false
          },
          title: {
            owner: 'hide',
            portrait: 'hide'
          }
        },
        name: name,
        description: description
      }
    end

    let(:upload_link) { Faker::Internet.url }

    let(:response_body) do
      {
        uri: '/videos/1234567890',
        link: 'https://vimeo.com/1234567890',
        upload: {
          upload_link: upload_link
        }
      }.to_json
    end

    before do
      school.configuration['vimeo_access_token'] = vimeo_access_token
      school.save!
    end

    it 'creates a new video' do
      stub_request(:post, "https://api.vimeo.com/me/videos/").
        with(
          body: expected_data.to_json,
          headers: {
            'Accept' => 'application/vnd.vimeo.*+json;version=3.4',
            'Authorization' => "Bearer #{vimeo_access_token}",
            'Content-Type' => 'application/json',
          }).
        to_return(status: 200, body: response_body)

      response = subject.create_video(size, name, description)

      expect(response['uri']).to eq('/videos/1234567890')
      expect(response['link']).to eq('https://vimeo.com/1234567890')
      expect(response['upload']['upload_link']).to eq(upload_link)
    end
  end

  describe '#add_allowed_domain_to_video' do
    let(:domain) { school.domains.first.fqdn }
    let(:video_id) { rand(100_000_000..999_999_999).to_s }

    before do

    end

    around do |example|
      original_value = Rails.application.secrets.vimeo_access_token
      Rails.application.secrets.vimeo_access_token = vimeo_access_token
      example.run
      Rails.application.secrets.vimeo_access_token = original_value
    end

    it 'adds an allowed domain to an existing video' do
      stub_request(:put, "https://api.vimeo.com/videos/#{video_id}/privacy/domains/#{domain}/").
        with(
          body: "{}",
          headers: {
            'Accept' => 'application/vnd.vimeo.*+json;version=3.4',
            'Authorization' => "Bearer #{vimeo_access_token}",
            'Content-Type' => 'application/json'
          })

      subject.add_allowed_domain_to_video(domain, video_id)
    end
  end
end
