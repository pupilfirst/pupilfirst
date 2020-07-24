after 'development:certificates', 'development:users' do
  puts 'Seeding issued_certificates'

  certificate = Certificate.find_by(name: 'V2')
  user = User.find_by(email: 'admin@example.com')

  certificate.issued_certificates.create!(
    user: user,
    name: user.name,
    serial_number: '200409-A1B2C3'
  )
end
