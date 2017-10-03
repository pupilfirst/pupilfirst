class TechHuntSignUpForm < Reform::Form
  validates_with CollegeIdOrTextValidator

  property :name, validates: { presence: true, length: { maximum: 250 } }
  property :email, virtual: true, validates: { presence: true, length: { maximum: 250 }, email: true }
  property :phone, validates: { presence: true, mobile_number: true }
  property :college_id, validates: { presence: true }
  property :college_text, validates: { length: { maximum: 250 } }

  def save
    # TODO: Find or create Player record & email the link to continue.
    true
  end
end
