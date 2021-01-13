module Types
  class StudentEnrollmentInputType < Types::BaseInputObject
    argument :name, String, required: true
    argument :email, String, required: true
    argument :title, String, required: false
    argument :affiliation, String, required: false
    argument :team_name, String, required: false
    argument :tags, [String], required: true
  end
end
