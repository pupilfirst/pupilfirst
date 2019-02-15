pdf_path = 'spec/support/uploads/resources/pdf-sample.pdf'

video_path = 'spec/support/uploads/resources/video-sample.mp4'

after 'development:targets' do
  puts 'Seeding resources'

  target = Startup.find_by(name: 'The Avengers').level.target_groups.first.targets.first
  school = target.course.school

  Resource.create!(
    file: Rails.root.join(pdf_path).open,
    title: 'Public PDF File',
    description: 'This is a public PDF file, meant to be accessible by everyone!',
    targets: [target],
    public: true,
    school: school,
    tag_list: %w(PDF)
  )

  Resource.create!(
    title: 'Public Link',
    description: 'This is a library entry with a link to an external resource',
    link: 'https://www.google.com',
    targets: [target],
    public: true,
    school: school,
    tag_list: %w(Link)
  )

  Resource.create!(
    file: Rails.root.join(video_path).open,
    title: 'Public MP4 File',
    description: 'This is an MP4 video, which we should be able to stream.',
    targets: [target],
    public: true,
    school: school,
    tag_list: %w(Video)
  )

  Resource.create!(
    video_embed: '<iframe width="560" height="315" src="https://www.youtube.com/embed/nkzqJ-9u4Aw" frameborder="0" allowfullscreen></iframe>',
    title: 'Public Embedded Video',
    description: 'This is a YouTube embed. It should be playable from the page.',
    targets: [target],
    public: true,
    school: school,
    tag_list: %w(Video)
  )

  Resource.create!(
    file: Rails.root.join(pdf_path).open,
    title: 'PDF only for students',
    description: 'This is a restricted PDF file, meant to be accessible only by students',
    targets: [target],
    school: school,
    tag_list: %w(PDF)
  )
end
