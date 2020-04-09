class IssuedCertificatesController < ApplicationController
  layout 'student'

  # GET /c/:serial_number
  def verify
    @issued_certificate = IssuedCertificate.find_by(serial_number: params[:serial_number])
    raise_not_found if @issued_certificate.blank?
  end
end
