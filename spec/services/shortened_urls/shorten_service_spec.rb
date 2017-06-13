require 'rails_helper'

describe ShortenedUrls::ShortenService do
  subject { described_class.new(full_url) }

  let(:full_url) { 'https://www.google.com' }

  describe '#short_url' do
    it 'returns a shortened URL for a given link' do
      short_url = subject.short_url
      expect(short_url).to match(%r(^http://localhost:3000/r/[a-z0-9]{6}$))
    end

    it 'returns the same shortened URL for the same link, no matter how many times its called' do
      short_url = subject.short_url
      expect(short_url).to eq("http://localhost:3000/r/#{ShortenedUrl.last.unique_key}")

      # Generate with the same full URL.
      expect(described_class.new(full_url).short_url).to eq(short_url)

      # Try another URL. It should change.
      expect(described_class.new('https://www.twitter.com')).not_to eq(short_url)
    end

    context 'when a generated unique key has already been used' do
      it 'generates another unique key' do
        allow(subject).to receive(:unique_key).and_return('foobar', 'foobaz')
        create(:shortened_url, unique_key: 'foobar')
        expect(subject.short_url).to eq('http://localhost:3000/r/foobaz')
      end
    end

    context 'when a generated unique key is detected as used more than 5 times in a row' do
      it 'raises an exception' do
        allow(subject).to receive(:unique_key).and_return('foobar', 'foobaz', 'barfoo', 'barbaz', 'bazfoo', 'bazbar')
        create(:shortened_url, unique_key: 'foobar')
        create(:shortened_url, unique_key: 'foobaz')
        create(:shortened_url, unique_key: 'barfoo')
        create(:shortened_url, unique_key: 'barbaz')
        create(:shortened_url, unique_key: 'bazfoo')
        create(:shortened_url, unique_key: 'bazbar')

        expect { subject.short_url }.to raise_error('Too many retries to generate unique_key for short URL.')
      end
    end
  end
end
