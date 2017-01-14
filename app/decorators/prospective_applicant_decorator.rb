class ProspectiveApplicantDecorator < Draper::Decorator
  delegate_all

  def form
    @form ||= BatchApplications::ProspectiveApplicantForm.new(model)
  end

  def submitted?
    h.session[:prospective_applicant_email].present?
  end
end
