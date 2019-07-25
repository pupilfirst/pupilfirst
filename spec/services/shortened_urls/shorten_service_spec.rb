require 'rails_helper'

describe ShortenedUrls::ShortenService do
  subject { described_class.new(full_url, host: 'example.com') }

  let(:full_url) { 'https://www.google.com' }

  describe '#short_url' do
    it 'returns a shortened URL for a given link' do
      short_url = subject.short_url
      expect(short_url).to match(%r(^http://example.com/r/[a-z0-9]{6}$))
    end

    it 'returns the same shortened URL for the same link, no matter how many times its called' do
      short_url = subject.short_url
      expect(short_url).to eq("http://example.com/r/#{ShortenedUrl.last.unique_key}")

      # Generate with the same full URL.
      expect(described_class.new(full_url, host: 'example.com').short_url).to eq(short_url)

      # Try another URL. It should change.
      expect(described_class.new('https://www.twitter.com', host: 'example.com').short_url).not_to eq(short_url)
    end

    context 'when a generated unique key has already been used' do
      it 'generates another unique key' do
        allow(subject).to receive(:unique_key).and_return('foobar', 'foobaz')
        create(:shortened_url, unique_key: 'foobar')
        expect(subject.short_url).to eq('http://example.com/r/foobaz')
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

    context 'when a unique key is supplied' do
      subject { described_class.new(full_url, unique_key: 'unique-key', host: 'example.com') }

      it 'uses the supplied unique key' do
        expect(subject.short_url).to eq('http://example.com/r/unique-key')
      end

      context 'when a different unique key is supplied for existing URL' do
        it 'updates the unique key in use' do
          create :shortened_url, url: full_url, unique_key: 'old-key'
          expect { subject.short_url }.to change { ShortenedUrl.find_by(url: full_url).unique_key }.from('old-key').to('unique-key')
        end

        context 'when the supplied key is in use' do
          it 'raises an exception' do
            create :shortened_url, url: 'https://twitter.com', unique_key: 'unique-key'
            expect { subject.short_url }.to raise_exception(ShortenedUrls::ShortenService::UniqueKeyUnavailable)
          end
        end
      end
    end
  end

  describe '#shortened_url' do
    context 'when expires_at is supplied' do
      let(:one_day_from_now) { Time.parse('2017-06-14 17:00:00 +0530') }
      subject { described_class.new(full_url, expires_at: one_day_from_now, host: 'example.com') }

      it 'sets the expiration time for new URL' do
        expect(subject.shortened_url.expires_at).to eq(one_day_from_now)
      end

      context 'when URL aready exists' do
        let(:one_day_ago) { Time.parse('2017-06-12 17:00:00 +0530') }

        it 'updates expiration time' do
          create :shortened_url, url: full_url, expires_at: one_day_ago

          expect { subject.shortened_url }.to change { ShortenedUrl.find_by(url: full_url).expires_at }.from(one_day_ago).to(one_day_from_now)
        end
      end
    end
  end
end
