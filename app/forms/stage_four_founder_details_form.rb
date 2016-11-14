class StageFourFounderDetailsForm < Reform::Form
  collection :batch_applicants do
    property :name
    property :role
    property :gender
    property :born_on
    property :parent_name
    property :current_address
    property :permanent_address
    property :phone
    property :id_proof_type
    property :id_proof_number
  end
end
