class ApplicationStageFourForm < Reform::Form
  property :id
  property :name
  property :email
  property :role
  property :gender
  property :born_on
  property :parent_name
  property :current_address
  property :current_address_is_permanent_address, virtual: true
  property :permanent_address
  property :phone
  property :id_proof_type
  property :id_proof_number

  def save
    raise NotImplementedError
  end
end
