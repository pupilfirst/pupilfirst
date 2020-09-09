after 'development:courses' do
  puts 'Seeding certificates'

  course = Course.first
  sample_certificate_path = Rails.root.join('spec', 'support', 'uploads', 'certificates', 'sample.png')
  common_properties = { name_offset_top: 59, font_size: 120, margin: 8, active: false }

  certificate_v1 = course.certificates.create!(
    common_properties.merge(name: 'V1', qr_corner: 'BottomLeft', qr_scale: 50)
  )

  certificate_v2 = course.certificates.create!(
    common_properties.merge(name: 'V2', qr_corner: 'TopRight', qr_scale: 75)
  )

  certificate_v3 = course.certificates.create!(
    common_properties.merge(name: 'V3', qr_corner: 'TopLeft', qr_scale: 100, active: true)
  )

  [certificate_v1, certificate_v2, certificate_v3].each do |certificate|
    certificate.image.attach(
      io: File.open(sample_certificate_path),
      filename: 'sample.png'
    )
  end

  certificate_v1.update!(created_at: 2.days.ago, updated_at: 2.days.ago)
  certificate_v2.update!(created_at: 1.day.ago, updated_at: 1.day.ago)
end
