module Students
  class RevokeIssuedCertificateService
    def initialize(issued_certificate)
      @issued_certificate = issued_certificate
    end

    def revoke(revoker:)
      return if @issued_certificate.revoked_at.present?

      @issued_certificate.update!(revoked_at: Time.zone.now, revoker: revoker)
      @issued_certificate
    end
  end
end
