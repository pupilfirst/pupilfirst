after 'development:courses' do
  puts 'Seeding certificates'

  course = Course.first

  certificate = course.certificates.create!(
    qr_corner: 'TopRight',
    name_offset_top: 45,
    font_size: 140,
    margin: 8,
    active: true
  )

  certificate.image.attach(
    io: File.open(Rails.root.join('spec', 'support', 'uploads', 'certificates', 'sample.png')),
    filename: 'sample.png'
  )
end
