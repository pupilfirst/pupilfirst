module Types
  class ApplicantSortCriterionType < Types::BaseEnum
    value 'CreatedAt', 'Sort list of applicants by creation time'
    value 'UpdatedAt', 'Sort list of applicants by last activity time'
    value 'Name', 'Sort list of applicants alphabetically'
  end
end
