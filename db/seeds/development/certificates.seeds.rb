after 'development:courses' do
  puts 'Seeding certificates'

  course = Course.first

  certificate = course.certificates.create!(
    qr_corner: 'top_right',
    name_offset_top: 60,
    active: true
  )

  certificate.image.attach(
    io: File.open(Rails.root.join('spec', 'support', 'uploads', 'certificates', 'sample.png')),
    filename: 'sample.png'
  )
end
