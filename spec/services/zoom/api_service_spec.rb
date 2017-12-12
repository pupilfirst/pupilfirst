require 'rails_helper'

describe Zoom::ApiService do
  subject { described_class.new }

  let(:response) { double 'RestClient Response' }

  describe '#post' do
    it 'sends a POST request with the correct payload and headers' do
      full_url = 'https://api.zoom.us/v2/some_method'
      payload = { some_property: 'value' }
      header = { Authorization: 'Bearer jwt_token', content_type: :json }

      # Stubs as required.
      expect(JWT).to receive(:encode).with(hash_including(exp: kind_of(Integer), iss: 'api_key'), 'api_secret', 'HS256').and_return('jwt_token')
      expect(RestClient).to receive(:post).with(full_url, payload.to_json, header).and_return(response)

      expect(subject.post('some_method', payload)).to eq(response)
    end
  end

  # TODO: Spec '#get' and '#path' if and when we end up using them.
end
