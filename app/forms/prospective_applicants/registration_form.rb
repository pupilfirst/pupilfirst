module ProspectiveApplicants
  class RegistrationForm < Reform::Form
    include CollegeAddable
    include AdmissionsPrepopulatable

    property :name, validates: { presence: true, length: { maximum: 250 } }
    property :email, validates: { presence: true, email: true, length: { maximum: 250 } }
    property :phone, validates: { presence: true, mobile_number: true }
    property :college_id, validates: { presence: true }
    property :college_text, validates: { length: { maximum: 250 } }

    def save
      prospective_applicant = ProspectiveApplicant.with_email(email)
      prospective_applicant = ProspectiveApplicant.new(email: email) if prospective_applicant.blank?

      prospective_applicant.update!({
        name: name,
        phone: phone
      }.merge(college_details))

      prospective_applicant
    end
  end
end
