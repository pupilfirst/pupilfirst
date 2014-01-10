require 'spec_helper'

describe News do
	context 'Createing news' do
		it "will strips youtube url to id" do
			news = build(:news)
			news.youtube_id = 'https://www.youtube.com/watch?v=foobar'
			expect(news.youtube_id).to eq('foobar')
			news.youtube_id = 'http://www.youtube.com/watch?v=foobar'
			expect(news.youtube_id).to eq('foobar')
			news.youtube_id = 'https://youtube.com/watch?v=foobar'
			expect(news.youtube_id).to eq('foobar')
			news.youtube_id = 'youtube.com/watch?v=foobar'
			expect(news.youtube_id).to eq('foobar')
		end
	end
end
