class ProspectiveApplicantDecorator < Draper::Decorator
  delegate_all

  def submitted?
    h.session[:prospective_applicant_email].present?
  end
end
