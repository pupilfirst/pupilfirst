class ProspectiveApplicantForm < Reform::Form
  include CollegeAddable

  property :name, validates: { presence: true, length: { maximum: 250 } }
  property :email, validates: { presence: true, email: true, length: { maximum: 250 } }
  property :phone, validates: { presence: true, indian_mobile_number: true }
  property :college_id, validates: { presence: true }
  property :college_text, validates: { length: { maximum: 250 } }

  def save
    ProspectiveApplicant.where(email: email).first_or_create!({
      name: name,
      phone: phone
    }.merge(college_details))
  end
end
