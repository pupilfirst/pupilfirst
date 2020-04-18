FactoryBot.define do
  factory :issued_certificate do
    certificate
    user
    name { user.name }
    serial_number { IssuedCertificates::SerialNumberService.generate }
  end
end
