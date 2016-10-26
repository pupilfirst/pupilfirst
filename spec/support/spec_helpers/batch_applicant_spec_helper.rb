module BatchApplicantSpecHelper
  def sign_in_batch_applicant(batch_applicant)
    login_path = apply_continue_path(token: batch_applicant.token, shared_device: false)
    visit(login_path)
  end
end
