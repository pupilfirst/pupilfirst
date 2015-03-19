require 'rails_helper'

describe News do
  let(:news) { build :news }

  context 'Creating news' do
    it 'will strip youtube URL to ID' do
      news.youtube_id = 'https://www.youtube.com/watch?v=foobar'
      expect(news.youtube_id).to eq('foobar')
      news.youtube_id = 'http://www.youtube.com/watch?v=foobar'
      expect(news.youtube_id).to eq('foobar')
      news.youtube_id = 'https://youtube.com/watch?v=foobar'
      expect(news.youtube_id).to eq('foobar')
      news.youtube_id = 'youtube.com/watch?v=foob-a_r'
      expect(news.youtube_id).to eq('foob-a_r')
      news.youtube_id = 'youtube.com/watch?v=foobar#t=34'
      expect(news.youtube_id).to eq('foobar')
      news.youtube_id = 'http://www.youtube.com/watch?v=Xvq6gOKkow8'
      expect(news.youtube_id).to eq('Xvq6gOKkow8')
    end

    it 'will normalize youtube_ID to nil if empty string is passed' do
      news.youtube_id = ' '
      expect(news.youtube_id).to eq(nil)
      news.youtube_id = nil
      expect(news.youtube_id).to eq(nil)
    end

    it 'will give youtube thumbnail URLs for respective ID' do
      youtube_id = 'foobar'
      news.youtube_id = youtube_id
      expect(news.youtube_thumbnail_url).to eq("http://img.youtube.com/vi/#{youtube_id}/hqdefault.jpg")
      expect(news.youtube_thumbnail_url(:max)).to eq("http://img.youtube.com/vi/#{youtube_id}/maxresdefault.jpg")
      expect(news.youtube_thumbnail_url(:high)).to eq("http://img.youtube.com/vi/#{youtube_id}/hqdefault.jpg")
      expect(news.youtube_thumbnail_url(:mid)).to eq("http://img.youtube.com/vi/#{youtube_id}/mqdefault.jpg")
      expect(news.youtube_thumbnail_url(:low)).to eq("http://img.youtube.com/vi/#{youtube_id}/default.jpg")
      expect(news.youtube_thumbnail_url(:var0)).to eq("http://img.youtube.com/vi/#{youtube_id}/0.jpg")
      expect(news.youtube_thumbnail_url(:var1)).to eq("http://img.youtube.com/vi/#{youtube_id}/1.jpg")
      expect(news.youtube_thumbnail_url(:var2)).to eq("http://img.youtube.com/vi/#{youtube_id}/3.jpg")
      expect(news.youtube_thumbnail_url(:var3)).to eq("http://img.youtube.com/vi/#{youtube_id}/4.jpg")
      expect(news.youtube_thumbnail_url(:xyz)).to eq("http://img.youtube.com/vi/#{youtube_id}/default.jpg")
    end

    it 'will assign published_at before_create' do
      news.youtube_id = 'foobar'
      news.save!
      expect(news.published_at.to_s).to eq(news.created_at.to_s)
    end
  end

  context 'update a News as featured' do
    let(:news) { create(:news, youtube_id: 'foobar') }

    before do
      allow(news).to receive(:send_push_notification)
    end

    it 'sends push if assign news item as featured for first time' do
      expect(news).to receive(:send_push_notification)
      news.update_attributes!(featured: true)
    end

    context 'if news item is re-asigned as featured' do
      let(:news) { create(:news, youtube_id: 'foobar', notification_sent: true) }

      it 'does not send push message' do
        expect(news).not_to receive(:send_push_notification)
        news.update_attributes!(featured: true)
      end
    end
  end
end
