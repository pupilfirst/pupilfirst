class IssuedCertificatesController < ApplicationController
  # GET /c/:serial_number
  def verify
    @issued_certificate = IssuedCertificate.find_by(serial_number: params[:serial_number])
    raise_not_found if @issued_certificate.blank?
    render layout: 'student'
  end

  # GET /c/:serial_number/print
  def print
    @issued_certificate = IssuedCertificate.find_by(serial_number: params[:serial_number])
    raise_not_found if @issued_certificate.blank?
    render layout: 'tailwind'
  end
end
