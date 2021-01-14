after 'development:targets' do
  puts 'Seeding content_blocks'

  def sort_index
    [1, 2, 3, 4].shuffle
  end

  def embed_codes
    [{ url: 'https://vimeo.com/201762745', code: '<iframe src="https://player.vimeo.com/video/201762745?app_id=122963" width="640" height="360" frameborder="0" title="India\" allow="autoplay; fullscreen" allowfullscreen></iframe>' },
      { url: 'https://www.youtube.com/watch?v=58CPRi5kRe8', code: '<iframe width="480" height="270" src="https://www.youtube.com/embed/58CPRi5kRe8?feature=oembed" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>' },
      { url: 'https://www.slideshare.net/hari/svcos-iterative-product-development', code: '<iframe src="https://www.slideshare.net/slideshow/embed_code/key/DImhwPhsvovNub" width="427" height="356" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;" allowfullscreen> </iframe> <div style="margin-bottom:5px"> <strong> <a href="https://www.slideshare.net/hari/svcos-iterative-product-development" title="SV.CO’s iterative product development" target="_blank">SV.CO’s iterative product development</a> </strong> from <strong><a href="https://www.slideshare.net/hari" target="_blank">hari</a></strong> </div>' }
    ]
  end

  Course.all.each do |course|
    course.targets.each do |target|
      target_version = target.target_versions.create!
      embed = embed_codes.sample
      target_version.content_blocks.create!(block_type: 'markdown', content: { markdown: Faker::Markdown.sandwich(sentences: 6, repeat: 3) }, sort_index: 1)
      image_cb = target_version.content_blocks.create!(block_type: 'image', content: { caption: Faker::Lorem.sentence(word_count: 3), width: 'Auto' }, sort_index: 2)

      image_cb.file.attach(
        io: File.open(Rails.root.join('spec', 'support', 'uploads', 'faculty', 'jack_sparrow.png')),
        filename: 'jack_sparrow.png'
      )

      file_cb = target_version.content_blocks.create!(block_type: 'file', content: { title: Faker::Lorem.sentence(word_count: 3) }, sort_index: 3)

      file_cb.file.attach(
        io: File.open(Rails.root.join('spec', 'support', 'uploads', 'files', 'pdf-sample.pdf')),
        filename: 'pdf-sample.pdf'
      )

      target_version.content_blocks.create!(block_type: 'embed', content: { url: embed[:url], embed_code: embed[:code], request_source: 'User' }, sort_index: 4)
    end
  end
end

