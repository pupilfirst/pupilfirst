FactoryBot.define do
  factory :content_block do
    sequence(:sort_index) { |n| n }
    target_version

    trait :empty_markdown do
      block_type { ContentBlock::BLOCK_TYPE_MARKDOWN }
      content { { markdown: '' } }
    end

    trait :markdown do
      block_type { ContentBlock::BLOCK_TYPE_MARKDOWN }
      content { { markdown: Faker::Markdown.sandwich(sentences: 5) } }
    end

    trait :image do
      block_type { ContentBlock::BLOCK_TYPE_IMAGE }
      file { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/uploads/files/icon_pupilfirst.png'), 'image/png') }
      content { { caption: Faker::Lorem.sentence, width: 'Auto' } }
    end

    trait :file do
      block_type { ContentBlock::BLOCK_TYPE_FILE }
      file { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/uploads/files/pdf-sample.pdf'), 'application/pdf') }
      content { { title: Faker::Lorem.words(number: 3).join(" ").titleize } }
    end

    trait :embed do
      block_type { ContentBlock::BLOCK_TYPE_EMBED }
      content do
        [
          {
            url: "https://vimeo.com/15298502",
            embed_code: "<iframe src=\"https://player.vimeo.com/video/15298502?app_id=122963\" width=\"480\" height=\"270\" frameborder=\"0\" title=\"Happy Punisher\" allow=\"autoplay; fullscreen\" allowfullscreen></iframe>",
            request_source: 'User'
          },
          {
            url: "https://www.youtube.com/watch?v=3QDYbQIS8cQ",
            embed_code: "<iframe width=\"480\" height=\"270\" src=\"https://www.youtube.com/embed/3QDYbQIS8cQ?feature=oembed\" frameborder=\"0\" allow=\"accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture\" allowfullscreen></iframe>",
            request_source: 'User'
          },
          {
            url: "https://www.slideshare.net/erickjones014/amazing-fact-about-cats-72889434",
            embed_code: "<iframe src=\"https://www.slideshare.net/slideshow/embed_code/key/sy7hfDK8aAqhO\" width=\"427\" height=\"356\" frameborder=\"0\" marginwidth=\"0\" marginheight=\"0\" scrolling=\"no\" style=\"border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;\" allowfullscreen> </iframe> <div style=\"margin-bottom:5px\"> <strong> <a href=\"https://www.slideshare.net/erickjones014/amazing-fact-about-cats-72889434\" title=\"Amazing Fact About Cats\" target=\"_blank\">Amazing Fact About Cats</a> </strong> from <strong><a href=\"https://www.slideshare.net/erickjones014\" target=\"_blank\">erickjones014</a></strong> </div>\n\n",
            request_source: 'User'
          }
        ].sample
      end
    end

    trait :coaching_session do
      block_type { ContentBlock::BLOCK_TYPE_COACHING_SESSION }
      content { { last_resolved_atn: Time.now } }
    end

    trait :pdf_document do
      block_type { ContentBlock::BLOCK_TYPE_PDF_DOCUMENT }
      file { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/uploads/files/pdf-sample.pdf'), 'application/pdf') }
      content { { title: Faker::Lorem.words(number: 3).join(" ").titleize } }
    end

    trait :community_widget_group do
      block_type { ContentBlock::BLOCK_TYPE_COMMUNITY_WIDGET }
      content { { type: 'group', slug: Faker::Lorem.words(number: 3).join("-"), components: [] } }
    end

    trait :community_widget_question do
      block_type { ContentBlock::BLOCK_TYPE_COMMUNITY_WIDGET }
      content { { type: 'question', slug: Faker::Lorem.words(number: 3).join("-"), components: [] } }
    end

    trait :community_widget_post do
      block_type { ContentBlock::BLOCK_TYPE_COMMUNITY_WIDGET }
      content { { type: 'post', slug: Faker::Lorem.words(number: 3).join("-"), components: [] } }
    end
  end
end
