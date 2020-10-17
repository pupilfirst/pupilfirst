module Students
  class RevokeIssuedCertificateService
    def initialize(issued_certificate, revoked_by)
      @issued_certificate = issued_certificate
      @revoked_by = revoked_by
    end

    def revoke
      return if @issued_certificate.revoked_at.present?

      @issued_certificate.update!(revoked_at: Time.zone.now, revoked_by: @revoked_by)

      @issued_certificate
    end
  end
end
