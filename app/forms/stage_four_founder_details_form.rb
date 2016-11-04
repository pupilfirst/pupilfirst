class StageFourFounderDetailsForm < Reform::Form
  collection :batch_applicants do
    property :name
    property :role
    property :born_on
    property :guardian_name
    property :guardian_relation
    property :current_address
    property :permanent_address
    property :phone
    property :id_proof_number
  end
end
