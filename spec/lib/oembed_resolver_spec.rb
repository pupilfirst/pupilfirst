require 'rails_helper'

describe Oembed::Resolver do
  subject { described_class }

  describe '#embed_code' do
    context 'when supplied a YouTube URL' do
      let(:expected_embed_code) { "\u003ciframe width=\"480\" height=\"270\" src=\"https:\/\/www.youtube.com\/embed\/3QDYbQIS8cQ?feature=oembed\" frameborder=\"0\" allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen\u003e\u003c\/iframe\u003e" }

      before do
        stub_request(:get, 'https://www.youtube.com/oembed?format=json&url=https://www.youtube.com/watch?v=3QDYbQIS8cQ').to_return(body: '{"version":"1.0","provider_name":"YouTube","html":"\u003ciframe width=\"480\" height=\"270\" src=\"https:\/\/www.youtube.com\/embed\/3QDYbQIS8cQ?feature=oembed\" frameborder=\"0\" allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen\u003e\u003c\/iframe\u003e","thumbnail_url":"https:\/\/i.ytimg.com\/vi\/3QDYbQIS8cQ\/hqdefault.jpg","provider_url":"https:\/\/www.youtube.com\/","thumbnail_height":360,"type":"video","height":270,"thumbnail_width":480,"author_url":"https:\/\/www.youtube.com\/channel\/UCvsvW3QH1700y-j2VfEnq-A","author_name":"Just smile","title":"Funny And Cute Cats - Funniest Cats Compilation 2019","width":480}', status: 200)
        stub_request(:get, 'https://www.youtube.com/oembed?format=json&url=https://youtu.be/3QDYbQIS8cQ').to_return(body: '{"author_url":"https:\/\/www.youtube.com\/channel\/UCvsvW3QH1700y-j2VfEnq-A","version":"1.0","thumbnail_height":360,"type":"video","provider_url":"https:\/\/www.youtube.com\/","provider_name":"YouTube","width":480,"thumbnail_width":480,"thumbnail_url":"https:\/\/i.ytimg.com\/vi\/3QDYbQIS8cQ\/hqdefault.jpg","height":270,"html":"\u003ciframe width=\"480\" height=\"270\" src=\"https:\/\/www.youtube.com\/embed\/3QDYbQIS8cQ?feature=oembed\" frameborder=\"0\" allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen\u003e\u003c\/iframe\u003e","author_name":"Just smile","title":"Funny And Cute Cats - Funniest Cats Compilation 2019"}', status: 200)
      end

      it 'returns embed code for YouTube' do
        expect(subject.new('https://www.youtube.com/watch?v=3QDYbQIS8cQ').embed_code).to eq(expected_embed_code)
        expect(subject.new('https://youtu.be/3QDYbQIS8cQ').embed_code).to eq(expected_embed_code)
      end
    end

    context 'when supplied a Vimeo URL' do
      let(:expected_embed_code) { "<iframe src=\"https://player.vimeo.com/video/15298502?app_id=122963\" width=\"480\" height=\"270\" frameborder=\"0\" title=\"Happy Punisher\" allow=\"autoplay; fullscreen\" allowfullscreen></iframe>" }

      before do
        stub_request(:get, 'https://vimeo.com/api/oembed.json?url=https://vimeo.com/15298502').to_return(body: '{"type":"video","version":"1.0","provider_name":"Vimeo","provider_url":"https:\/\/vimeo.com\/","title":"Happy Punisher","author_name":"Ryan Shelley","author_url":"https:\/\/vimeo.com\/barnapkins","is_plus":"1","account_type":"plus","html":"<iframe src=\"https:\/\/player.vimeo.com\/video\/15298502?app_id=122963\" width=\"480\" height=\"270\" frameborder=\"0\" title=\"Happy Punisher\" allow=\"autoplay; fullscreen\" allowfullscreen><\/iframe>","width":480,"height":270,"duration":103,"description":"I find this video relaxing.","thumbnail_url":"https:\/\/i.vimeocdn.com\/video\/91917335_295x166.webp","thumbnail_width":295,"thumbnail_height":166,"thumbnail_url_with_play_button":"https:\/\/i.vimeocdn.com\/filter\/overlay?src0=https%3A%2F%2Fi.vimeocdn.com%2Fvideo%2F91917335_295x166.webp&src1=http%3A%2F%2Ff.vimeocdn.com%2Fp%2Fimages%2Fcrawler_play.png","upload_date":"2010-09-26 11:34:00","video_id":15298502,"uri":"\/videos\/15298502"}', status: 200)
      end

      it 'returns embed code for Vimeo' do
        expect(subject.new('https://vimeo.com/15298502').embed_code).to eq(expected_embed_code)
      end
    end

    context 'when supplied a Slideshare URL' do
      let(:expected_embed_code) { "<iframe src=\"https://www.slideshare.net/slideshow/embed_code/key/sy7hfDK8aAqhO\" width=\"427\" height=\"356\" frameborder=\"0\" marginwidth=\"0\" marginheight=\"0\" scrolling=\"no\" style=\"border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;\" allowfullscreen> </iframe> <div style=\"margin-bottom:5px\"> <strong> <a href=\"https://www.slideshare.net/erickjones014/amazing-fact-about-cats-72889434\" title=\"Amazing Fact About Cats\" target=\"_blank\">Amazing Fact About Cats</a> </strong> from <strong><a href=\"https://www.slideshare.net/erickjones014\" target=\"_blank\">erickjones014</a></strong> </div>\n\n" }

      before do
        stub_request(:get, 'https://www.slideshare.net/api/oembed/2?format=json&url=https://www.slideshare.net/erickjones014/amazing-fact-about-cats-72889434').to_return(body: '{"version":"1.0","type":"rich","title":"Amazing Fact About Cats","author_name":"erickjones014","author_url":"https://www.slideshare.net/erickjones014","provider_name":"SlideShare","provider_url":"https://www.slideshare.net/","html":"\u003Ciframe src=\"https://www.slideshare.net/slideshow/embed_code/key/sy7hfDK8aAqhO\" width=\"427\" height=\"356\" frameborder=\"0\" marginwidth=\"0\" marginheight=\"0\" scrolling=\"no\" style=\"border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;\" allowfullscreen\u003E \u003C/iframe\u003E \u003Cdiv style=\"margin-bottom:5px\"\u003E \u003Cstrong\u003E \u003Ca href=\"https://www.slideshare.net/erickjones014/amazing-fact-about-cats-72889434\" title=\"Amazing Fact About Cats\" target=\"_blank\"\u003EAmazing Fact About Cats\u003C/a\u003E \u003C/strong\u003E from \u003Cstrong\u003E\u003Ca href=\"https://www.slideshare.net/erickjones014\" target=\"_blank\"\u003Eerickjones014\u003C/a\u003E\u003C/strong\u003E \u003C/div\u003E\n\n","width":425,"height":355,"thumbnail":"//cdn.slidesharecdn.com/ss_thumbnails/amazingfactaboutcats-170307071323-thumbnail.jpg?cb=1488870850","thumbnail_url":"https://cdn.slidesharecdn.com/ss_thumbnails/amazingfactaboutcats-170307071323-thumbnail.jpg?cb=1488870850","thumbnail_width":170,"thumbnail_height":128,"total_slides":22,"conversion_version":2,"slide_image_baseurl":"//image.slidesharecdn.com/amazingfactaboutcats-170307071323/95/slide-","slide_image_baseurl_suffix":"-1024.jpg","version_no":"1488870850","slideshow_id":72889434}', status: 200)
      end

      it 'returns embed code for Slideshare' do
        expect(subject.new('https://www.slideshare.net/erickjones014/amazing-fact-about-cats-72889434').embed_code).to eq(expected_embed_code)
      end
    end

    context 'when supplied a Google Slides URL' do
      let(:pasted_link) { 'https://docs.google.com/presentation/d/e/SLIDES-CODE/pub?start=false&loop=false&delayms=3000' }
      let(:expected_embed_code) { "<iframe src='https://docs.google.com/presentation/d/e/SLIDES-CODE/embed?start=false&loop=false&delayms=3000' frameborder='0' width='960' height='572' allowfullscreen='true' mozallowfullscreen='true' webkitallowfullscreen='true'></iframe>" }

      it 'returns embed code for Google Slides' do
        expect(subject.new(pasted_link).embed_code).to eq(expected_embed_code)
      end
    end

    context 'when supplied a Google Docs URL' do
      let(:pasted_link) { 'https://docs.google.com/document/d/e/DOCS-CODE/pub' }
      let(:expected_embed_code) { "<iframe src='https://docs.google.com/document/d/e/DOCS-CODE/pub?embedded=true' frameborder='0' width='960' height='572' allowfullscreen='true' mozallowfullscreen='true' webkitallowfullscreen='true'></iframe>" }

      it 'returns embed code for Google Slides' do
        expect(subject.new(pasted_link).embed_code).to eq(expected_embed_code)
      end
    end

    context 'when supplied a Google Forms URL' do
      let(:pasted_link) { 'https://docs.google.com/forms/d/e/FORMS-CODE/viewform?usp=sf_link' }
      let(:expected_embed_code) { "<iframe src='https://docs.google.com/forms/d/e/FORMS-CODE/viewform?embedded=true' frameborder='0' width='960' height='572' allowfullscreen='true' mozallowfullscreen='true' webkitallowfullscreen='true'></iframe>" }

      it 'returns embed code for Google Slides' do
        expect(subject.new(pasted_link).embed_code).to eq(expected_embed_code)
      end
    end

    context 'when supplied a Google Spreadsheets URL' do
      let(:pasted_link) { 'https://docs.google.com/spreadsheets/d/e/SPREADSHEET-CODE/pubhtml' }
      let(:expected_embed_code) { "<iframe src='https://docs.google.com/spreadsheets/d/e/SPREADSHEET-CODE/pubhtml?widget=true&headers=false' frameborder='0' width='960' height='572' allowfullscreen='true' mozallowfullscreen='true' webkitallowfullscreen='true'></iframe>" }

      it 'returns embed code for Google Slides' do
        expect(subject.new(pasted_link).embed_code).to eq(expected_embed_code)
      end
    end

    context 'when supplied an unknown URL' do
      it 'raises Oembed::Resolver::ProviderNotSupported' do
        expected_error_message = "The hostname 'speakerdeck.com' could not be resolved to any known provider."

        expect { subject.new('https://speakerdeck.com/hiroki6/monad-error-with-cats').embed_code }.to(
          raise_error(Oembed::Resolver::ProviderNotSupported, expected_error_message)
        )
      end
    end
  end
end
