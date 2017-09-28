pdf_path = 'spec/support/uploads/resources/pdf-sample.pdf'
pdf_thumbnail_path = 'spec/support/uploads/resources/pdf-thumbnail.png'

video_path = 'spec/support/uploads/resources/video-sample.mp4'
video_thumbnail_path = 'spec/support/uploads/resources/video-thumbnail.png'

puts 'Seeding resources'

Resource.create!(
  file: Rails.root.join(pdf_path).open,
  thumbnail: Rails.root.join(pdf_thumbnail_path).open,
  title: 'Public PDF File',
  description: 'This is a public PDF file, meant to be accessible by everyone!'
)

Resource.create!(
  file: Rails.root.join(video_path).open,
  thumbnail: Rails.root.join(video_thumbnail_path).open,
  title: 'Public MP4 File',
  description: 'This is an MP4 video, which we should be able to stream.'
)

Resource.create!(
  video_embed: '<iframe width="560" height="315" src="https://www.youtube.com/embed/nkzqJ-9u4Aw" frameborder="0" allowfullscreen></iframe>',
  thumbnail: Rails.root.join(video_thumbnail_path).open,
  title: 'Public Embedded Video',
  description: 'This is a YouTube embed. It should be playable from the page.'
)

Resource.create!(
  file: Rails.root.join(pdf_path).open,
  title: 'PDF for approved startups',
  description: 'This is a restricted PDF file, meant to be accessible by approved startups!'
)

after 'development:levels' do
  level_one = Level.find_by(number: 1)

  Resource.create!(
    file: Rails.root.join(pdf_path).open,
    thumbnail: Rails.root.join(pdf_thumbnail_path).open,
    title: 'PDF for level 1+ startups',
    description: 'This is a restricted PDF file, meant to be accessible by approved startups of level 1 and above.',
    level: level_one
  )
end
