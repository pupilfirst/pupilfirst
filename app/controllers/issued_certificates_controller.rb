class IssuedCertificatesController < ApplicationController
  # GET /c/:serial_number
  def verify
    @issued_certificate = IssuedCertificate.find_by(serial_number: params[:serial_number])
    raise_not_found if @issued_certificate.blank? || @issued_certificate.revoked_at.present?
    render layout: 'student'
  end
end
