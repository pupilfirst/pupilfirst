# Mails related to issued certificates.
class IssuedCertificateMailer < SchoolMailer
  # Mail sent when a certificate is newly issued.
  #
  # @param issued_certificate [IssuedCertificate]
  def issued(issued_certificate)
    @issued_certificate = issued_certificate
    @course = @issued_certificate.course
    @school = @issued_certificate.user.school
    simple_mail(
      @issued_certificate.user.email,
      I18n.t('mailers.issued_certificate.issued.subject')
    )
  end
end
