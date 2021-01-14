class IssuedCertificatesController < ApplicationController
  # GET /c/:serial_number
  def verify
    @issued_certificate = IssuedCertificate.find_by(serial_number: params[:serial_number], revoked_at: nil)
    raise_not_found if @issued_certificate.blank?
    render layout: 'student'
  end
end
