after 'development:targets' do
  puts 'Seeding content_blocks'

  def sort_index
    [1, 2, 3, 4].shuffle
  end

  Course.all.each do |course|
    course.targets.each do |target|
      content_sort_index = sort_index
      ContentBlock.create!(target: target, sort_index: content_sort_index[0], block_type: 'markdown', content: { markdown: Faker::Markdown.sandwich(6, 3) })
      image_cb = ContentBlock.create!(target: target, sort_index: content_sort_index[1], block_type: 'image', content: { caption: Faker::Lorem.sentence(3) })
      image_cb.file.attach(
        io: File.open(Rails.root.join('spec', 'support', 'uploads', 'faculty', 'jack_sparrow.png')),
        filename: 'jack_sparrow.png'
      )
      file_cb = ContentBlock.create!(target: target, sort_index: content_sort_index[2], block_type: 'file', content: { title: Faker::Lorem.sentence(3) })
      file_cb.file.attach(io: File.open(Rails.root.join('spec', 'support', 'uploads', 'resources', 'pdf-sample.pdf')),
        filename: 'pdf-sample.pdf')
      ContentBlock.create!(target: target, sort_index: content_sort_index[3], block_type: 'embed', content: { url: 'https://www.youtube.com/watch?v=58CPRi5kRe8', embed_code: '<iframe width="480" height="270" src="https://www.youtube.com/embed/58CPRi5kRe8?feature=oembed" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>' })
    end
  end
end

