class IssuedCertificateMailerPreview < ActionMailer::Preview
  def issued
    IssuedCertificateMailer.issued(IssuedCertificate.first)
  end
end
