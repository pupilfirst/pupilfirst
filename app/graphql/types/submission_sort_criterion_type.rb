module Types
  class SubmissionSortCriterionType < Types::BaseEnum
    value 'SubmittedAt', 'Sort list of submissions by submission date'
    value 'EvaluatedAt', 'Sort list of submissions by evaluated date'
  end
end
