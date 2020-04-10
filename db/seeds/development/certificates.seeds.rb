after 'development:courses' do
  puts 'Seeding certificates'

  course = Course.first

  certificate = course.certificates.create!(
    qr_corner: 'TopRight',
    qr_scale: 100,
    name_offset_top: 57,
    font_size: 140,
    margin: 8,
    active: true
  )

  certificate.image.attach(
    io: File.open(Rails.root.join('spec', 'support', 'uploads', 'certificates', 'sample.png')),
    filename: 'sample.png'
  )
end
